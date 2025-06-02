// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '< polycule >';

  @override
  String get about => '关于';

  @override
  String author(String author) {
    return '作者：$author';
  }

  @override
  String get appSlogan => '为高阶用户打造的极客高效 [matrix] 客户端。';

  @override
  String get repoLabel => '源代码（GitLab）';

  @override
  String get releaseNotes => '更新日志';

  @override
  String get buyMeACoffee => '请我喝杯咖啡';

  @override
  String get homeserverHeadline => 'Haj！欢迎来到 < polycule >';

  @override
  String get aMatrixClient => '- 又一个 [matrix] 客户端';

  @override
  String get connectToHomeserver => '连接到您的主服务器';

  @override
  String get discoverHomeservers => '发现新主服务器';

  @override
  String get newToMatrixLong =>
      '在 [matrix] 宇宙中查找可用主服务器。此操作将连接到 joinmatrix.org。';

  @override
  String get connect => '连接';

  @override
  String get homeserverNotValid => '这不是有效的主服务器输入。';

  @override
  String get pleaseProvideHomeserver => '请提供主服务器。';

  @override
  String errorConnectingToHomeserver(String homeserver) {
    return '无法连接 $homeserver。请检查您的选择。';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return '正在连接 $homeserver …';
  }

  @override
  String welcomeToHomeserver(String homeserver) {
    return '欢迎来到 $homeserver！';
  }

  @override
  String get howWouldYouLikeToConnect => '您想如何连接？';

  @override
  String get loginPassword => '使用密码登录';

  @override
  String get loginLegacySso => '使用传统 SSO 登录';

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get pleaseProvideEmail => '请提供您的邮箱。';

  @override
  String get pleaseProvidePassword => '请输入您的密码。';

  @override
  String get pleaseProvideUsername => '请输入您的用户名。';

  @override
  String get emailMinimals => '您的邮箱必须至少包含 @ 符号、本地部分和域名。';

  @override
  String get mxidSyntax => '允许的字符：a-z、0-9 以及符号 ., _, =, -, / 和 +。';

  @override
  String clientDisplayName(String platform) {
    return '< polycule > 于 $platform';
  }

  @override
  String clientDisplayNameHostname(String hostname, String platform) {
    return '< polycule > 于 $hostname（$platform）';
  }

  @override
  String get platformWeb => '网页';

  @override
  String get loginError => '无法登录；请检查您的凭据。';

  @override
  String loginErrorMessage(String message) {
    return '无法登录：$message';
  }

  @override
  String hajUser(String? localpart) {
    return 'Haj $localpart！';
  }

  @override
  String get syncInProgress => '同步进行中';

  @override
  String get initialSync => '初始同步进行中';

  @override
  String get syncOffline => '同步中断';

  @override
  String get syncFunctional => '同步状态正常';

  @override
  String lastSyncReceived(DateTime timestamp, int duration) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jms(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return '上次同步：$timestampString（$duration 毫秒）';
  }

  @override
  String editedToday(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jm(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return '编辑时间：$timestampString';
  }

  @override
  String editedAt(String timestamp) {
    return '编辑时间：$timestamp';
  }

  @override
  String get authenticationRequired => '需要身份验证';

  @override
  String authenticateForAccount(String mxid) {
    return '请使用您的凭据验证 $mxid。';
  }

  @override
  String replyUserSentDate(String username, String formattedDate) {
    return '$username 写于 $formattedDate：';
  }

  @override
  String get view => '查看';

  @override
  String get passphraseNotEmpty => '密码短语不能为空';

  @override
  String get cancel => '取消';

  @override
  String get noMatch => '无匹配项';

  @override
  String get keysMatch => '密钥匹配';

  @override
  String get wipeAccount => '清除账号';

  @override
  String get wipeAccountWarning => '如果您丢失了设备，可以清除并重置账号。所有消息和聊天将会丢失。';

  @override
  String get deleteAll => '全部删除';

  @override
  String get previous => '上一个';

  @override
  String get next => '下一个';

  @override
  String get connectPreviousDevice => '连接之前的设备';

  @override
  String get connectPreviousDeviceLong => '请验证现有设备。';

  @override
  String get deviceNotAvailable => '我无法使用我的设备。';

  @override
  String get compareSasNumbers => '比较 SAS 安全数字';

  @override
  String get compareSasEmojis => '比较 SAS 安全表情符号';

  @override
  String get compareSasExplanation => '请检查您设备上的 SAS 是否与请求验证的另一台设备上的 SAS 完全一致。';

  @override
  String get incomingVerificationRequest => '收到验证请求';

  @override
  String get waitingForVerification => '等待验证';

  @override
  String get waitingForVerificationFallback => '请使用您的第二台设备验证或输入恢复短语。';

  @override
  String incomingVerificationRequestUser(String? user) {
    return '$user 想要进行验证';
  }

  @override
  String get incomingVerificationRequestMyself => '收到验证请求，需要为您的账号验证另一台设备。';

  @override
  String get incomingVerificationRequestLong => '收到验证请求，您想处理该验证请求吗？';

  @override
  String get reject => '拒绝';

  @override
  String get proceed => '继续';

  @override
  String get enterRecoveryPhrase => '输入恢复短语';

  @override
  String get keyVerificationErrorGeneric => '验证您的设备时发生错误。';

  @override
  String get keyVerificationErrorUser => '验证已取消。';

  @override
  String get close => '关闭';

  @override
  String get verificationSuccessful => '密钥验证成功';

  @override
  String get verifyLogin => '验证您的密钥材料';

  @override
  String get finish => '完成';

  @override
  String get or => '或';

  @override
  String get verifyWithOtherDevice => '使用其它设备进行验证';

  @override
  String get verifyMethodsNotAvailable => '您没有可用的验证方法？';

  @override
  String get resetAccountWarning => '您将失去所有过去的消息。这无法撤销。';

  @override
  String get verifyWithPassphrase => '使用短语进行验证';

  @override
  String get passphraseNoWhitespace => '短语不能包含任何空格字符！';

  @override
  String get errorTryAgain => '发生错误。请重试。';

  @override
  String get submit => '提交';

  @override
  String get togglePassword => '切换密码可见性';

  @override
  String get loggingInToClient => '登录账号';

  @override
  String get pendingInvite => '待处理邀请';

  @override
  String get invite => '邀请';

  @override
  String inviteLongRoom(String roomname) {
    return '您被邀请加入房间：「$roomname」。';
  }

  @override
  String inviteLongDM(Object displayname) {
    return '您被邀请与「$displayname」进行交流。';
  }

  @override
  String roomParticipants(int participants) {
    String _temp0 = intl.Intl.pluralLogic(
      participants,
      locale: localeName,
      other: '$participants 名参与者',
      one: '1 名参与者',
      zero: '没有参与者',
    );
    return '$_temp0';
  }

  @override
  String get joinRoom => '加入房间';

  @override
  String get knockRoom => '请求加入';

  @override
  String get youCannotJoinThisRoom => '您无法加入此房间。';

  @override
  String get addAccount => '添加另一个账号';

  @override
  String get regionAccountSwitcher => '屏幕区域：账号切换器。';

  @override
  String get regionChatContents => '屏幕区域：聊天内容。';

  @override
  String get loadingHomeservers => '正在加载服务器。进度未知。请等待。';

  @override
  String get send => '发送';

  @override
  String get typeGroupImages => '图片';

  @override
  String get typeGroupVideos => '视频';

  @override
  String get typeGroupAudio => '音频';

  @override
  String get typeGroupFiles => '所有文件';

  @override
  String get msgTypeText => '发送普通文本消息。';

  @override
  String get msgTypeEmote => '描述您的心情。';

  @override
  String get msgTypeNotice => '发送机器人无法回复的信息。';

  @override
  String get msgTypeImage => '发送图片文件。';

  @override
  String get msgTypeVideo => '发送视频文件。';

  @override
  String get msgTypeAudio => '发送音频文件。';

  @override
  String get msgTypeFile => '发送文件。';

  @override
  String get msgTypeLocation => '分享您的位置。';

  @override
  String get msgTypeSticker => '发送贴纸。';

  @override
  String get msgTypeBadEncrypted => '向您的同行发送无法解密的消息。';

  @override
  String get msgTypeNone => '未发送消息。';

  @override
  String sendingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files 个文件',
      one: '1 个文件',
      zero: '未发送文件。',
    );
    return '$_temp0 正在发送...';
  }

  @override
  String get noFilesSelected => '未选择文件。';

  @override
  String get yesterday => '昨天';

  @override
  String get thisMonth => '本月';

  @override
  String get lastMonth => '上月';

  @override
  String get download => '下载';

  @override
  String get share => '分享';

  @override
  String get saveAs => '另存为';

  @override
  String get settings => '设置';

  @override
  String get errorDownloadingAttachment => '下载消息附件时发生错误。';

  @override
  String get retry => '重试';

  @override
  String get searchPromptLabel => '命令、用户、房间名称或 MXID';

  @override
  String get appearanceAccessibilitySettings => '外观和辅助功能';

  @override
  String get polyculeSettings => '配置您的 < polycule >';

  @override
  String get systemLanguage => '设备语言';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get dark => '深色终端';

  @override
  String get light => '浅色玫瑰';

  @override
  String get systemTheme => '系统主题';

  @override
  String get fontAccessibility => '字体辅助功能';

  @override
  String get inclusiveSans => '提高可读性的字体';

  @override
  String get openDyslexic => '帮助阅读障碍的字体';

  @override
  String get serif => '衬线字体';

  @override
  String get defaultFont => '默认字体';

  @override
  String get color => '颜色设置';

  @override
  String get systemColor => '系统颜色';

  @override
  String get defaultColor => '主题默认颜色';

  @override
  String get customColor => '自定义颜色';

  @override
  String get highContrast => '高对比度';

  @override
  String get aboutPolycule => '关于 < polycule >';

  @override
  String contentNotice(String notice) {
    return '内容警告：「$notice」';
  }

  @override
  String get contentNoticeFallback => '内容警告';

  @override
  String get webUriHandlerTitle => '< polycule > [matrix] 客户端';

  @override
  String jumpToMessage(String message) {
    return '跳转到消息 $message';
  }

  @override
  String get selectAccount => '选择账号继续';

  @override
  String sharingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files 个文件',
      one: '一个文件',
    );
    return '正在发送 $_temp0。';
  }

  @override
  String get sharingText => '分享文本到房间';

  @override
  String get sendFiles => '发送文件';

  @override
  String get checkingTotalSendSize => '正在检查总发送大小...';

  @override
  String totalSendSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: '总发送大小：$size 字节',
      one: '总发送大小：1 字节',
      zero: '总发送大小：0 字节',
    );
    return '$_temp0';
  }

  @override
  String fileSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: '文件大小：$size 字节',
      one: '文件大小：1 字节',
      zero: '文件大小：0 字节',
    );
    return '$_temp0';
  }

  @override
  String mimeType(String? mimeType) {
    return '文件类型：$mimeType';
  }

  @override
  String matrixRoomShareSubject(String roomname) {
    return '在 [matrix] 加入房间 « $roomname »';
  }

  @override
  String matrixUserShareSubject(String mxid) {
    return '在 [matrix] 联系 « $mxid »';
  }

  @override
  String fileDownloadedTo(String name) {
    return '文件已保存为 « $name »。';
  }

  @override
  String get openFile => '打开';

  @override
  String get compressFiles => '压缩文件';

  @override
  String get compressFilesSubtitle => '仅支持的文件类型';

  @override
  String get cancelSending => '取消发送';

  @override
  String get retrySending => '重试发送';

  @override
  String get accountSettings => '账号设置';

  @override
  String get previewRoom => '以访客身份预览';

  @override
  String get joinMatrixCall => '加入 [matrix] 通话';

  @override
  String matrixCallTooltip(String roomId) {
    return '通话 ID：$roomId';
  }

  @override
  String get pushSettings => '推送通知';

  @override
  String get unifiedPushUnavailable => '您的设备上无法使用 UnifiedPush。';

  @override
  String get selectPushDistributor => '选择您的 UnifiedPush 分发器';

  @override
  String get disablePushNotifications => '禁用推送通知';

  @override
  String get pushInformationPolycule =>
      '目前，< polycule > 仅支持 Android 上的推送通知。Linux 支持正在计划中。';

  @override
  String get unifiedPushAbout =>
      '您需要安装分发器才能使推送通知正常工作。\n您可以在此了解更多信息：https://unifiedpush.org/users/intro/';

  @override
  String get unifiedPushLink => 'https://unifiedpush.org/users/intro/';

  @override
  String get setupUnifiedPush => '设置 UnifiedPush';

  @override
  String get googleFirebase => 'Google Firebase 云消息';

  @override
  String get newNotification => '在 < polycyule > 中有新消息';

  @override
  String get pushChannelName => '收到的消息';

  @override
  String get directChats => '私聊房间';

  @override
  String get groups => '群组房间';

  @override
  String get unifiedPush => 'UnifiedPush';

  @override
  String get reply => '回复';

  @override
  String get edit => '编辑';

  @override
  String get redact => '撤回';

  @override
  String get copyMessage => '复制消息';

  @override
  String get confirmRedact => '撤回事件';

  @override
  String redactEventLong(String eventId) {
    return '您确定要永久撤回事件 $eventId 吗？';
  }

  @override
  String get logoutCommandSyntax => '退出此账号。';

  @override
  String get roomnameCommandSyntax => '将房间名称设置为 [name]。';

  @override
  String get roomdescriptionCommandSyntax => '将房间描述设置为 [description]。';

  @override
  String get sendCommandSyntax => '发送文本消息。[m.text]';

  @override
  String get meCommandSyntax => '描述您的心情。[m.emote]';

  @override
  String get dmCommandSyntax => '创建一个私聊房间。[mxid] [--no-encryption?]';

  @override
  String get createCommandSyntax => '创建一个房间。[name?] [--no-encryption?]';

  @override
  String get plainCommandSyntax => '发送不带 markdown 解析的文本消息。[m.text]';

  @override
  String get htmlCommandSyntax => '以原始 HTML 格式发送文本消息。[m.text]';

  @override
  String get reactCommandSyntax => '用表情回复。[reaction]';

  @override
  String get joinCommandSyntax => '加入房间。[mxid]';

  @override
  String get leaveCommandSyntax => '离开当前房间。';

  @override
  String get opCommandSyntax => '设置成员权限等级。[mxid] [50?]';

  @override
  String get kickCommandSyntax => '踢出成员。[mxid]';

  @override
  String get banCommandSyntax => '封禁成员。[mxid]';

  @override
  String get unbanCommandSyntax => '解除封禁成员。[mxid]';

  @override
  String get inviteCommandSyntax => '邀请成员。[mxid]';

  @override
  String get myroomnickCommandSyntax => '在此房间设置自定义昵称。[displayname]';

  @override
  String get myroomavatarCommandSyntax => '在此房间设置自定义 mxc 头像。[mxc]';

  @override
  String get discardsessionCommandSyntax => '丢弃您的房间会话。';

  @override
  String get clearcacheCommandSyntax => '清除账号本地缓存。';

  @override
  String get markasdmCommandSyntax => '将当前房间标记为与某成员的私聊。[mxid]';

  @override
  String get markasgroupCommandSyntax => '将当前房间从私聊列表中移除。';

  @override
  String get hugCommandSyntax => '发送虚拟拥抱。';

  @override
  String get googlyCommandSyntax => '发送虚拟滑稽眼睛。';

  @override
  String get cuddleCommandSyntax => '发送虚拟依偎。';

  @override
  String get sendrawCommandSyntax => '发送原始事件。[content]';

  @override
  String get ignoreCommandSyntax => '忽略用户。[mxid]';

  @override
  String get unignoreCommandSyntax => '取消忽略用户。[mxid]';

  @override
  String get noErrorReported => '未报告任何错误。';

  @override
  String get commandInvalid => '这不是有效的 < polycule > 命令。';

  @override
  String get commandHelp => '显示帮助';

  @override
  String get availableCommands => '可用命令';

  @override
  String get commandError => '退出码 1';

  @override
  String get noStickerPacks => '您的账号和此房间都没有可用的贴纸包。';

  @override
  String get react => '发送表情';

  @override
  String get logs => '应用日志';

  @override
  String get reload => '重新加载';

  @override
  String get runtimeError => '您的 < polycule > 出现了问题';

  @override
  String get logSingleError => '匿名分享';

  @override
  String get enableSentry => '始终分享';

  @override
  String get errorReporting => '错误报告';

  @override
  String get errorReportingLong => '您可以启用错误报告，帮助在 < polycule > 中查找漏洞。';

  @override
  String get errorReportingPrivacy =>
      '这将连接到 < polycyle > 的源代码托管平台 GitLab.com，并匿名分享发生的错误及其原因。不会向开发者分享任何个人数据。';

  @override
  String get learnMore => '了解更多';

  @override
  String get gitLabPrivacy =>
      'https://gitlab.com/help/operations/error_tracking.md';

  @override
  String get fontSize => '字体大小';

  @override
  String get reset => '重置';

  @override
  String fontScaleLabel(double scale) {
    final intl.NumberFormat scaleNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String scaleString = scaleNumberFormat.format(scale);

    return '$scaleString';
  }

  @override
  String get openDirectChat => '打开私聊';

  @override
  String get startDirectChat => '开始私聊';

  @override
  String get ignoreUser => '忽略';

  @override
  String get unignoreUser => '取消忽略';

  @override
  String get ignoreToggleWaiting => '正在处理忽略状态。这将需要一些时间。';

  @override
  String get roomStateWtf => '此房间的安全性很混乱。最好避免进入。';

  @override
  String get roomStatePublic => '此房间对所有人公开可见';

  @override
  String get roomStatePublicKnock => '此房间对所有人公开可见，但加入前必须敲门。';

  @override
  String get roomStateOpen => '知道链接的任何人都可以加入此房间。';

  @override
  String get roomStateKnock => '用户必须敲门后才能加入此房间。';

  @override
  String get roomStateSpace => '此房间仅对空间成员开放。';

  @override
  String get roomStateUnpublic => '此房间为私有，但未加密。';

  @override
  String get roomStateEncrypted => '此房间已加密，但部分成员未验证。';

  @override
  String get roomStateVerifiedEncrypted => '此房间已加密，且每个会话都已交叉签名。';

  @override
  String get oidcAppName => '< polycule >';

  @override
  String get oidcContact => 'info@braid.business';

  @override
  String get oidcLogoPath => 'assets/assets/logo/logo-circle.png';

  @override
  String get oidcTosPath => 'tos.html';

  @override
  String get oidcPolicyPath => 'policy.html';

  @override
  String get loginOidc => '使用 OpenID Connect 登录';

  @override
  String get oidcConfirm => '确认';

  @override
  String get manageSessions => '管理会话';

  @override
  String get deactivateAccount => '停用账号';

  @override
  String get networkSettings => '网络设置';

  @override
  String get useSystemProxy => '允许设备代理设置';

  @override
  String get verifyCertificates => '验证 TLS 证书';

  @override
  String get verifyTlsCertificatesAndroid =>
      '对于较旧的 Android 版本，已包含轮换后的 Let\'s Encrypt ISRG ROOT X1 证书。';

  @override
  String get sendTlsSNI => '发送明文服务器名称指示';

  @override
  String get minTlsVersion => '主服务器所需的最低 TLS 版本';

  @override
  String get tls12 => 'TLS 1.2';

  @override
  String get tls13 => 'TLS 1.3';

  @override
  String get favoriteAdd => '添加到收藏';

  @override
  String get favoriteRemove => '从收藏中移除';

  @override
  String get markRead => '标记为已读';

  @override
  String get markUnread => '标记为未读';

  @override
  String get leaveRoom => '离开房间';

  @override
  String leaveRoomLong(String name) {
    return '请确认永久离开房间「$name」。';
  }

  @override
  String get userDetails => '查看用户资料';

  @override
  String get markMute => '静音房间';

  @override
  String get markUnmute => '取消静音房间';

  @override
  String get copyRoomAddress => '复制公共房间地址';

  @override
  String get search => '搜索';

  @override
  String get startVerification => '开始验证';

  @override
  String get keyVerificationRequestSent => '密钥验证请求已发送。';

  @override
  String get noHomeserverConnection => '无法连接到主服务器。';

  @override
  String get emojiSettings => '表情设置';

  @override
  String get defaultEmojiTone => '默认表情色调';

  @override
  String get autoplayAnimations => '自动播放动图和贴纸';

  @override
  String get yellowSkin => '黄色皮肤';

  @override
  String get paleSkin => '浅色皮肤';

  @override
  String get demiPaleSkin => '半浅色皮肤';

  @override
  String get mediumSkin => '中等皮肤';

  @override
  String get brownSkin => '棕色皮肤';

  @override
  String get blackSkin => '黑色皮肤';

  @override
  String get roomDetails => '房间详情';

  @override
  String get errorSendingSticker => '发送自定义贴纸时出错。';

  @override
  String get viewSourceCode => '查看源代码';

  @override
  String get eventSourceCode => '事件源代码';

  @override
  String get eventSourceContent => '事件内容';

  @override
  String get eventSourceJson => '完整 JSON';

  @override
  String get eventSourceOriginal => '原始事件';

  @override
  String get eventSourceBodyRaw => '事件内容（原始）';

  @override
  String get eventSourceBodyHtml => '事件内容（HTML）';

  @override
  String get eventSourceUnsigned => '未签名内容';

  @override
  String get eventRendered => '已渲染事件';

  @override
  String get eventQuoted => '引用的事件';

  @override
  String get eventPreview => '事件预览';

  @override
  String get blurHash => '模糊哈希';

  @override
  String get linuxOidcWorkaround =>
      '如果您的网页浏览器在登录后没有提示您打开 < polycule >，请确保您已授权 < polycule > 处理 OAuth2.0 重定向，可在终端模拟器中运行以下命令：';

  @override
  String get linuxOidcWorkaroundSnippet =>
      'gio mime x-scheme-handler/im.polycule business.braid.polycule.desktop';

  @override
  String get setupSSSSLoading => '正在进行加密设置。这可能需要一些时间。';

  @override
  String get sessionId => '会话 ID';

  @override
  String get sessionIpAddress => '上次 IP 地址';

  @override
  String get sessionLastSeen => '上次活跃';

  @override
  String get delete => '删除';

  @override
  String get verify => '验证';

  @override
  String get verifyAgain => '再次验证';

  @override
  String get rename => '重命名';

  @override
  String get renameDevice => '重命名设备';

  @override
  String get deviceName => '设备显示名称';

  @override
  String get renameDeviceHint => '留空以移除显示名称';

  @override
  String get openInIDP => '在身份提供方中打开';

  @override
  String get deviceNoEncryption => '不支持加密';

  @override
  String get deviceVerified => '密钥已验证';

  @override
  String get deviceUnverified => '密钥未验证';

  @override
  String get deviceBlocked => '设备已屏蔽';

  @override
  String get logout => '退出登录';

  @override
  String get logoutWarning => '确认退出登录';

  @override
  String get logoutWarningLong => '当您退出登录且没有其它会话或恢复短语时，您将无法访问所有 [matrix] 消息。';

  @override
  String get keyBackupAvailable => 'SSSS 备份';

  @override
  String get keyBackupExplanation => '使用安全密钥存储与共享功能，为您所有设备安全备份消息密钥。';

  @override
  String get ssssRecoveryKey => 'SSSS 恢复密钥';

  @override
  String get ssssRecoveryKeyExplanation =>
      '请将您的安全密钥存储与共享恢复密钥妥善保管在安全的地方。没有恢复密钥，所有历史消息将永久丢失。';

  @override
  String get confirmSSSSKeyStored => '密钥已存储';

  @override
  String get yourCurrentDevice => '您当前的设备';

  @override
  String get moveClientTooltip => '移动到此处';

  @override
  String get displayName => '显示名称';

  @override
  String get yourDisplayName => '您的显示名称';

  @override
  String get displayNameHint => '此名称将显示在您的公开资料上。';

  @override
  String get changeDisplayName => '更改显示名称';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get compareSas => '比较 SAS 密钥';

  @override
  String get confirmQrScanned => '二维码扫描成功。';

  @override
  String get confirm => '确认';

  @override
  String get scanQrWithOtherDevice => '请用您的其它设备扫描此二维码。';

  @override
  String get clientSwitcher => '切换账号';

  @override
  String get block => '屏蔽';

  @override
  String get unblock => '取消屏蔽';

  @override
  String get sessions => '会话';

  @override
  String get notificationSettings => 'Notification rules';

  @override
  String get notificationsGlobal => 'Generic';

  @override
  String get notificationsOverride => 'High';

  @override
  String get notificationsRoom => 'Rooms';

  @override
  String get notificationsSender => 'Senders';

  @override
  String get notificationsUnderride => 'Low';

  @override
  String get noPushRules => 'No push rules available.';

  @override
  String get defaultPushRule => 'This is a default push rule.';

  @override
  String get pushRuleEnabled => 'Enable push rule';

  @override
  String get eventContentMatches => 'Event content matches this pattern';

  @override
  String unknownAction(Object action) {
    return 'Unknown action : $action';
  }

  @override
  String get actionNotify => 'Send notification';

  @override
  String get actionDontNotify => 'Do not notify';

  @override
  String get notificationTweakSound => 'Sound';

  @override
  String get notificationTweakHighlight => 'Highlight';

  @override
  String unknownNotificationTweak(Object tweak) {
    return 'Unknown tweak : $tweak';
  }

  @override
  String pushConditionSenderNotificationPermission(Object key) {
    return 'Sender can notify : $key';
  }

  @override
  String get tweakEnabled => 'Enabled';

  @override
  String get tweakDisabled => 'Disabled';

  @override
  String get tweakDefault => 'Notification default';

  @override
  String get pushConditionContainsDisplayName => 'Contains my display name';

  @override
  String get pushRulesGlobal => 'Account wide';

  @override
  String get pushRulesDevice => 'This device';
}
