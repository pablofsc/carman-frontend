import 'package:flutter/material.dart';

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/models/auth_response.dart';

class AccountDetailsSheet extends StatelessWidget {
  final AuthResponse auth;

  const AccountDetailsSheet({super.key, required this.auth});

  static void show(BuildContext context, AuthResponse auth) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AccountDetailsSheet(auth: auth),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final expiryTime = auth.generatedAt.add(Duration(seconds: auth.expiresIn));
    final timeRemaining = expiryTime.difference(DateTime.now());
    final isExpiring = timeRemaining.inSeconds < 300;

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 20,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user.username,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            auth.user.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),
                    _buildUserCard(context, theme),
                    const SizedBox(height: 16),
                    _buildAuthCard(
                      context,
                      theme,
                      expiryTime,
                      timeRemaining,
                      isExpiring,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              context,
              Icons.person,
              context.l10n.username,
              auth.user.username,
            ),
            const Divider(),
            _infoRow(context, Icons.badge, context.l10n.userId, auth.user.id),
            const Divider(),
            _infoRow(
              context,
              Icons.language,
              context.l10n.language,
              auth.user.selectedLanguage ?? '-',
            ),
            const Divider(),
            _infoRow(
              context,
              Icons.attach_money,
              context.l10n.currency,
              auth.user.selectedCurrency ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard(
    BuildContext context,
    ThemeData theme,
    DateTime expiryTime,
    Duration timeRemaining,
    bool isExpiring,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              context,
              Icons.schedule,
              context.l10n.generatedAt,
              _formatDateTime(auth.generatedAt),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.expiresAt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDateTime(expiryTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _infoRow(
              context,
              Icons.timer,
              context.l10n.expiresIn,
              '${auth.expiresIn} ${context.l10n.seconds} (${(auth.expiresIn / 60).toStringAsFixed(1)} ${context.l10n.minutes})',
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_bottom,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.timeRemaining,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isExpiring)
                    Icon(Icons.warning, size: 18, color: Colors.orange),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m ${timeRemaining.inSeconds % 60}s',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _infoRow(
              context,
              Icons.info_outline,
              context.l10n.type,
              auth.tokenType,
            ),
            const Divider(),
            Row(
              children: [
                Icon(
                  Icons.vpn_key,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.accessToken,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              auth.accessToken,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
            const Divider(),
            Row(
              children: [
                Icon(
                  Icons.refresh,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.refreshToken,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              auth.refreshToken,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
