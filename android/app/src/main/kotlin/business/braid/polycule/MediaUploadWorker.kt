package business.braid.polycule

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin
import com.tekartik.sqflite.SqflitePlugin
import eu.simonbinder.sqlite3_flutter_libs.Sqlite3FlutterLibsPlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.pathprovider.PathProviderPlugin
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import java.util.concurrent.TimeUnit

class MediaUploadWorker(
    context: Context,
    parameters: WorkerParameters,
) : CoroutineWorker(context, parameters) {
    override suspend fun doWork(): Result {
        val jobId = inputData.getString(JOB_ID) ?: return Result.failure()
        var engine: FlutterEngine? = null
        return try {
            val completed = CompletableDeferred<Boolean>()
            engine = withContext(Dispatchers.Main) {
                // Never auto-register the complete application plugin set in
                // this headless engine. UnifiedPush keeps a process-wide
                // callback reference, so registering it here could redirect
                // incoming notifications into the upload isolate.
                FlutterEngine(
                    applicationContext,
                    null,
                    false,
                ).also { flutterEngine ->
                    flutterEngine.plugins.add(PathProviderPlugin())
                    flutterEngine.plugins.add(FlutterSecureStoragePlugin())
                    flutterEngine.plugins.add(SqflitePlugin())
                    flutterEngine.plugins.add(Sqlite3FlutterLibsPlugin())
                    flutterEngine.plugins.add(MatrixStoreLockPlugin())
                    MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        COMPLETION_CHANNEL,
                    ).setMethodCallHandler { call, result ->
                        if (call.method != "complete") {
                            result.notImplemented()
                        } else {
                            completed.complete(call.argument<Boolean>("success") == true)
                            result.success(null)
                        }
                    }
                    flutterEngine.dartExecutor.executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault(),
                        listOf(MEDIA_WORKER_ARGUMENT, jobId),
                    )
                }
            }
            val success = withTimeout(TimeUnit.MINUTES.toMillis(9)) {
                completed.await()
            }
            if (success) Result.success() else Result.retry()
        } catch (_: Throwable) {
            Result.retry()
        } finally {
            withContext(Dispatchers.Main) { engine?.destroy() }
        }
    }

    companion object {
        private const val SCHEDULER_CHANNEL = "polycule.media_uploads"
        private const val COMPLETION_CHANNEL = "polycule.media_upload_worker"
        private const val MEDIA_WORKER_ARGUMENT = "--media-upload-worker"
        private const val JOB_ID = "job_id"
        private const val UNIQUE_WORK_PREFIX = "polycule-media-upload-"

        fun attachScheduler(context: Context, messenger: BinaryMessenger) {
            MethodChannel(messenger, SCHEDULER_CHANNEL).setMethodCallHandler {
                call, result ->
                val jobId = call.argument<String>("jobId")
                if (jobId.isNullOrBlank()) {
                    result.error("INVALID_JOB", "Missing media upload job id", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "enqueue" -> {
                        enqueue(context, jobId)
                        result.success(null)
                    }
                    "cancel" -> {
                        WorkManager.getInstance(context)
                            .cancelUniqueWork("$UNIQUE_WORK_PREFIX$jobId")
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        private fun enqueue(context: Context, jobId: String) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
            val request = OneTimeWorkRequestBuilder<MediaUploadWorker>()
                .setInputData(Data.Builder().putString(JOB_ID, jobId).build())
                .setConstraints(constraints)
                .setInitialDelay(8, TimeUnit.SECONDS)
                .setBackoffCriteria(
                    BackoffPolicy.LINEAR,
                    10,
                    TimeUnit.SECONDS,
                )
                .addTag(UNIQUE_WORK_PREFIX)
                .build()
            WorkManager.getInstance(context).enqueueUniqueWork(
                "$UNIQUE_WORK_PREFIX$jobId",
                ExistingWorkPolicy.KEEP,
                request,
            )
        }
    }
}
