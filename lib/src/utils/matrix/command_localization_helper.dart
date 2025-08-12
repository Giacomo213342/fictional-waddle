import '../../../l10n/generated/app_localizations.dart';

class CommandLocalizationHelper {
  const CommandLocalizationHelper(this.l10n);

  final AppLocalizations l10n;

  String? lookupCommandDescription(String command) {
    switch (command) {
      // default commands
      case 'send':
        return l10n.sendCommandSyntax;
      case 'me':
        return l10n.meCommandSyntax;
      case 'dm':
        return l10n.dmCommandSyntax;
      case 'create':
        return l10n.createCommandSyntax;
      case 'plain':
        return l10n.plainCommandSyntax;
      case 'html':
        return l10n.htmlCommandSyntax;
      case 'react':
        return l10n.reactCommandSyntax;
      case 'join':
        return l10n.joinCommandSyntax;
      case 'leave':
        return l10n.leaveCommandSyntax;
      case 'op':
        return l10n.opCommandSyntax;
      case 'kick':
        return l10n.kickCommandSyntax;
      case 'ban':
        return l10n.banCommandSyntax;
      case 'unban':
        return l10n.unbanCommandSyntax;
      case 'invite':
        return l10n.inviteCommandSyntax;
      case 'myroomnick':
        return l10n.myroomnickCommandSyntax;
      case 'myroomavatar':
        return l10n.myroomavatarCommandSyntax;
      case 'discardsession':
        return l10n.discardsessionCommandSyntax;
      case 'clearcache':
        return l10n.clearcacheCommandSyntax;
      case 'markasdm':
        return l10n.markasdmCommandSyntax;
      case 'markasgroup':
        return l10n.markasgroupCommandSyntax;
      case 'hug':
        return l10n.hugCommandSyntax;
      case 'googly':
        return l10n.googlyCommandSyntax;
      case 'cuddle':
        return l10n.cuddleCommandSyntax;
      case 'sendraw':
        return l10n.sendrawCommandSyntax;
      case 'ignore':
        return l10n.ignoreCommandSyntax;
      case 'unignore':
        return l10n.unignoreCommandSyntax;
      // polycule commands
      case 'logout':
        return l10n.logoutCommandSyntax;
      case 'upgraderoom':
        return l10n.upgraderoomCommandSyntax;
      case 'roomname':
        return l10n.roomnameCommandSyntax;
      case 'roomdescription':
        return l10n.roomdescriptionCommandSyntax;

      default:
        return null;
    }
  }
}
