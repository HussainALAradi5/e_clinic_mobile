import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/staff/chat_text.dart';
import 'chat_avatar.dart';

/// Who is in the chat, with each colleague's work phone and email — tap to call or write. Members slide in one
/// after another.
class ChatInfoSheet extends StatelessWidget {
  const ChatInfoSheet({super.key, required this.chat});

  final Conversation chat;

  Future<void> _open(String scheme, String to) => launchUrl(Uri(scheme: scheme, path: to));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final members = [...chat.members]..sort((a, b) => a.isMe == b.isMe ? 0 : (a.isMe ? -1 : 1));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Center(
            child: PopIn(
              child: ChatAvatar(
                name: chat.title,
                seed: chat.partnerId ?? chat.id,
                url: chat.avatarUrl,
                group: chat.isGroup,
                size: 72,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(chat.title, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SectionHeader(ChatText.members),
          for (final (i, m) in members.indexed)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Motion.of(context, Motion.base + Duration(milliseconds: 60 * i)),
              curve: Motion.ease,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChatAvatar(name: m.fullName, seed: m.userId, url: m.avatarUrl, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.isMe ? '${m.fullName} · ${ChatText.you}' : m.fullName,
                              style: theme.textTheme.titleSmall,
                            ),
                            if (!m.isMe && m.phone != null)
                              _ContactLine(
                                icon: Icons.call_rounded,
                                text: m.phone!,
                                onTap: () => _open('tel', m.phone!),
                              ),
                            if (!m.isMe && m.email != null)
                              _ContactLine(
                                icon: Icons.mail_rounded,
                                text: m.email!,
                                onTap: () => _open('mailto', m.email!),
                              ),
                          ],
                        ),
                      ),
                      if (chat.isGroup && m.role == 'admin') Icon(Icons.star_rounded, color: scheme.tertiary, size: 20),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text, required this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return TapScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
