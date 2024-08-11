package business.braid.polycule

import android.content.Context
import org.unifiedpush.android.foss_embedded_fcm_distributor.EmbeddedDistributorReceiver

class EmbeddedDistributor : EmbeddedDistributorReceiver() {

    override val googleProjectNumber = "300667509591"

    override fun getEndpoint(context: Context, token: String, instance: String): String {
        return "https://fcm.polycule.im/FCM?v2&instance=$instance&token=$token"
    }
}
