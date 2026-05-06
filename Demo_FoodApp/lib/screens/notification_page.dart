import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import 'cafeteria_page.dart'; // Import to use CustomFloatingNavBar

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> notifications = [];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final email = AppSession.email;
      if (email.isEmpty) {
        throw Exception('User email is not available');
      }
      final result = await ApiService.getNotifications(customerEmail: email);
      if (!mounted) return;
      setState(() {
        notifications = result;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markNotificationRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      if (!mounted) return;
      setState(() {
        final index = notifications.indexWhere(
          (notif) => notif['_id'] == notificationId,
        );
        if (index != -1) {
          notifications[index]['read'] = true;
        }
      });
    } catch (_) {
      // Ignore read marking failures and keep showing notifications.
    }
  }

  Future<void> _markAllAsRead() async {
    final unread = notifications
        .where((notif) => notif['read'] != true)
        .toList();
    if (unread.isEmpty) return;

    try {
      await Future.wait(
        unread.map(
          (notif) => ApiService.markNotificationAsRead(notif['_id'].toString()),
        ),
      );
      if (!mounted) return;
      setState(() {
        notifications = notifications.map((notif) {
          return {...notif, 'read': true};
        }).toList();
      });
    } catch (_) {
      // Ignore failures
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF020617)
        : const Color(0xFFF4F6F9);
    final unreadCount = notifications
        .where((notif) => notif['read'] != true)
        .length;
    final title = unreadCount > 0
        ? 'Notifications ($unreadCount Unread)'
        : 'Notifications';
    final filteredNotifications = _selectedFilter == 0
        ? notifications.where((notif) => notif['read'] != true).toList()
        : notifications;

    return Scaffold(
      backgroundColor: background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(context, isDark, title),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildFilterChip(
                            'Unread',
                            0,
                            _selectedFilter == 0,
                            isDark,
                            unreadCount,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'All',
                            1,
                            _selectedFilter == 1,
                            isDark,
                            null,
                          ),
                        ],
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: _markAllAsRead,
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F4CFF),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFF0F4CFF),
                            ),
                          )
                        : errorMessage != null
                        ? _buildErrorState(isDark)
                        : filteredNotifications.isEmpty
                        ? _buildEmptyState(isDark, _selectedFilter)
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notif = filteredNotifications[index];
                                return _buildNotificationCard(
                                  context,
                                  notif,
                                  isDark,
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: 0,
        isDark: isDark,
        toggleTheme: () {},
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF0F4CFF),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F4CFF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int index,
    bool selected,
    bool isDark,
    int? count,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0F4CFF)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFF0F4CFF).withOpacity(0.18),
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF0F4CFF)),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (count != null)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white24 : const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF0F4CFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notif,
    bool isDark,
  ) {
    final isUnread = notif['read'] != true;
    final cardColor = isUnread
        ? (isDark ? const Color(0xFF102B49) : const Color(0xFFE8F0FF))
        : (isDark ? const Color(0xFF0F172A) : Colors.white);
    final textColor = isDark ? Colors.white : const Color(0xFF10254E);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          if (notif['_id'] != null && notif['read'] != true) {
            await _markNotificationRead(notif['_id'].toString());
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationDetailPage(
                title: notif['title']?.toString() ?? '',
                message: notif['message']?.toString() ?? '',
                items:
                    (notif['items'] as List<dynamic>?)
                        ?.map((item) => item.toString())
                        .toList() ??
                    [],
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: isDark ? Colors.white : const Color(0xFF0F4CFF),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif['title']?.toString() ?? '',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blueAccent.withOpacity(0.2)
                                : const Color(0xFF0F4CFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'UNREAD',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: isDark ? Colors.white : Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['message']?.toString() ?? '',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: subTextColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, int filterIndex) {
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final title = filterIndex == 0
        ? 'No unread notifications'
        : 'No notifications yet';
    final subtitle = filterIndex == 0
        ? 'You have read all notifications. Pull to refresh for new updates.'
        : 'No new notifications were found. Place an order to see updates here.';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: 80,
          color: subTextColor.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF10254E);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 72,
                color: isDark ? Colors.red.shade200 : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Unable to load notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String message;
  final List<String> items;

  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.message,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF020617)
        : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF10254E);
    final subText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(context, isDark, "Order Details"),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              "No items found",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: textColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.3 : 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : const Color(0xFFE8F0FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.fastfood_rounded,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F4CFF),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        items[index],
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: 0,
        isDark: isDark,
        toggleTheme: () {},
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark, String barTitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF0F4CFF),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            barTitle,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F4CFF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
