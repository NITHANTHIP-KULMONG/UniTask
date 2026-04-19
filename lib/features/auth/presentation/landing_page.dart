import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey _featuresKey = GlobalKey();

  void _openApp() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _scrollToFeatures() async {
    final sectionContext = _featuresKey.currentContext;
    if (sectionContext == null) return;

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      alignment: 0.06,
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 2,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ).copyWith(
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) return 10;
        return 2;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return const Color(0xFF4F46E5);
        }
        return const Color(0xFF6366F1);
      }),
    );
  }

  ButtonStyle _outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF4C5C9A), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ).copyWith(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return Colors.white.withValues(alpha: 0.08);
        }
        return Colors.transparent;
      }),
      side: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return const BorderSide(color: Color(0xFF7C8BC9), width: 1.2);
        }
        return const BorderSide(color: Color(0xFF4C5C9A), width: 1.2);
      }),
    );
  }

  TextTheme _landingTextTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.18,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFC7D2FE),
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFB9C3EE),
        height: 1.55,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTopNav(TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1431).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B4B8F).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'UniTask',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _openApp,
            style: _primaryButtonStyle().copyWith(
              padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Open App'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(TextTheme tt, bool compact) {
    final headline = tt.headlineLarge?.copyWith(
      fontSize: compact ? 40 : 56,
    );

    final subHeadline = tt.headlineMedium?.copyWith(
      fontSize: compact ? 28 : 34,
      color: const Color(0xFFDFE7FF),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3370).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF5F73D5).withValues(alpha: 0.7)),
          ),
          child: Text(
            'SaaS Productivity Platform',
            style: tt.bodyMedium?.copyWith(
              color: const Color(0xFFC8D3FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'จัดการงานของคุณอย่างมีประสิทธิภาพ',
          style: headline,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your tasks smarter and faster',
          style: subHeadline,
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'UniTask helps students and teams organize assignments, track progress, and stay on schedule with a clean, modern workflow powered by real-time sync.',
            style: tt.bodyLarge,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _openApp,
              style: _primaryButtonStyle(),
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Get Started'),
            ),
            OutlinedButton.icon(
              onPressed: _scrollToFeatures,
              style: _outlineButtonStyle(),
              icon: const Icon(Icons.south_rounded),
              label: const Text('Learn More'),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: const [
            _MetricItem(title: '10k+', subtitle: 'Tasks Organized'),
            _MetricItem(title: '99.9%', subtitle: 'Sync Uptime'),
            _MetricItem(title: '4.9/5', subtitle: 'User Satisfaction'),
          ],
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 26),
          Center(child: _PhoneMock(textTheme: tt)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: content),
        const SizedBox(width: 28),
        const Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.topRight,
            child: _PhoneMock(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required TextTheme tt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tt.headlineMedium?.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: tt.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildFeatures(TextTheme tt) {
    const features = [
      _FeatureItem(
        icon: Icons.task_alt_rounded,
        title: 'Task Management',
        description: 'Create, prioritize, and organize assignments with flexible status workflows.',
      ),
      _FeatureItem(
        icon: Icons.sync_rounded,
        title: 'Real-time Sync (Firebase)',
        description: 'Keep updates instant and consistent across your devices and sessions.',
      ),
      _FeatureItem(
        icon: Icons.notifications_active_rounded,
        title: 'Smart Notifications',
        description: 'Stay ahead of deadlines with timely reminders and follow-up prompts.',
      ),
      _FeatureItem(
        icon: Icons.auto_awesome_rounded,
        title: 'Clean UI & Theme Support',
        description: 'Enjoy focused interfaces with polished light/dark visual experiences.',
      ),
    ];

    return Container(
      key: _featuresKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Features',
            subtitle: 'Everything you need to plan, execute, and finish work with confidence.',
            tt: tt,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = width >= 1080
                  ? (width - 48) / 4
                  : width >= 760
                      ? (width - 16) / 2
                      : width;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: features
                    .map(
                      (feature) => SizedBox(
                        width: cardWidth,
                        child: _FeatureCard(item: feature, textTheme: tt),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(TextTheme tt) {
    const steps = [
      _StepItem(
        number: '1',
        title: 'Login / Register',
        description: 'Sign in securely and set up your personal workspace in seconds.',
      ),
      _StepItem(
        number: '2',
        title: 'Create Tasks',
        description: 'Add assignments, due dates, and priorities with an intuitive flow.',
      ),
      _StepItem(
        number: '3',
        title: 'Track Progress',
        description: 'Follow completion trends and finish tasks before deadlines arrive.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'How It Works',
          subtitle: 'Three simple steps to move from planning to execution.',
          tt: tt,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width >= 980 ? (width - 32) / 3 : width;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: steps
                  .map(
                    (step) => SizedBox(
                      width: cardWidth,
                      child: _StepCard(item: step, textTheme: tt),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppPreview(TextTheme tt) {
    const previews = [
      _PreviewItem(
        title: 'Dashboard Overview',
        subtitle: 'Quick view of tasks, deadlines, and activity.',
        icon: Icons.dashboard_rounded,
      ),
      _PreviewItem(
        title: 'Assignment Board',
        subtitle: 'Grouped status cards for easy prioritization.',
        icon: Icons.view_kanban_rounded,
      ),
      _PreviewItem(
        title: 'Focus Mode',
        subtitle: 'A distraction-light layout for deep work.',
        icon: Icons.center_focus_strong_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'App Preview',
          subtitle: 'A polished interface built for clarity and speed.',
          tt: tt,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width >= 980 ? (width - 32) / 3 : width;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: previews
                  .map(
                    (item) => SizedBox(
                      width: cardWidth,
                      child: _PreviewCard(item: item, textTheme: tt),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFaq(TextTheme tt) {
    const faqs = [
      _FaqItem(
        question: 'Is this app free?',
        answer: 'Yes. UniTask core features are free to use for students and individual users.',
      ),
      _FaqItem(
        question: 'Does it sync across devices?',
        answer: 'Yes. Task data is synchronized in real time across all signed-in devices.',
      ),
      _FaqItem(
        question: 'Can I use it offline?',
        answer: 'Yes. You can continue working offline, and data syncs automatically once online.',
      ),
      _FaqItem(
        question: 'Is my data secure?',
        answer: 'Yes. UniTask uses Firebase authentication and secure cloud storage rules.',
      ),
      _FaqItem(
        question: 'Can teams use UniTask together?',
        answer: 'Yes. Shared workflows and collaborative task visibility are supported.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'FAQ',
          subtitle: 'Answers to common questions before you start.',
          tt: tt,
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111A39).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF3A4A86).withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2A5A).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      iconColor: const Color(0xFFC7D2FE),
                      collapsedIconColor: const Color(0xFFC7D2FE),
                      title: Text(
                        item.question,
                        style: tt.titleMedium,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      tilePadding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.answer,
                            style: tt.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != faqs.length - 1)
                    Divider(
                      height: 1,
                      color: const Color(0xFF3A4A86).withValues(alpha: 0.6),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(TextTheme tt, bool compact) {
    final linkStyle = TextButton.styleFrom(
      foregroundColor: const Color(0xFFB9C3EE),
      textStyle: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    ).copyWith(
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) return const Color(0xFFE0E7FF);
        return const Color(0xFFB9C3EE);
      }),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF33427D).withValues(alpha: 0.65)),
        color: const Color(0xFF0D1330).withValues(alpha: 0.92),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UniTask',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copyright © 2026 UniTask. All rights reserved.',
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    TextButton(onPressed: _openApp, style: linkStyle, child: const Text('GitHub')),
                    TextButton(onPressed: _openApp, style: linkStyle, child: const Text('Contact')),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UniTask',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Copyright © 2026 UniTask. All rights reserved.',
                      style: tt.bodyMedium,
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(onPressed: _openApp, style: linkStyle, child: const Text('GitHub')),
                const SizedBox(width: 6),
                TextButton(onPressed: _openApp, style: linkStyle, child: const Text('Contact')),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.width < 900;
    final tt = _landingTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: const Color(0xFF070B1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF080D21),
              Color(0xFF0E1531),
              Color(0xFF121A3B),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              left: -80,
              child: _GlowOrb(
                size: 340,
                color: Color(0xFF6366F1),
                alpha: 0.22,
              ),
            ),
            const Positioned(
              top: 240,
              right: -110,
              child: _GlowOrb(
                size: 300,
                color: Color(0xFF22D3EE),
                alpha: 0.15,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FadeInSection(delayMs: 0, child: _buildTopNav(tt)),
                        const SizedBox(height: 32),
                        _FadeInSection(
                          delayMs: 80,
                          child: _buildHero(tt, compact),
                        ),
                        const SizedBox(height: 68),
                        _FadeInSection(
                          delayMs: 160,
                          child: _buildFeatures(tt),
                        ),
                        const SizedBox(height: 64),
                        _FadeInSection(
                          delayMs: 240,
                          child: _buildHowItWorks(tt),
                        ),
                        const SizedBox(height: 64),
                        _FadeInSection(
                          delayMs: 320,
                          child: _buildAppPreview(tt),
                        ),
                        const SizedBox(height: 64),
                        _FadeInSection(
                          delayMs: 400,
                          child: _buildFaq(tt),
                        ),
                        const SizedBox(height: 56),
                        _FadeInSection(
                          delayMs: 480,
                          child: _buildFooter(tt, compact),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeInSection extends StatefulWidget {
  const _FadeInSection({
    required this.child,
    required this.delayMs,
  });

  final Widget child;
  final int delayMs;

  @override
  State<_FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<_FadeInSection> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: alpha),
              blurRadius: size * 0.4,
              spreadRadius: size * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tt = GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111A3A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3A4B86).withValues(alpha: 0.58)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: tt.bodySmall?.copyWith(
              color: const Color(0xFFB9C3EE),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneMock extends StatelessWidget {
  const _PhoneMock({this.textTheme});

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    final tt = textTheme ?? GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme);

    Widget buildTaskItem(String title, String time, Color dotColor) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2650),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              time,
              style: tt.bodySmall?.copyWith(
                color: const Color(0xFFB9C3EE),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 350,
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A3370), Color(0xFF121A3D)],
        ),
        border: Border.all(color: const Color(0xFF5C72D8).withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27377E).withValues(alpha: 0.5),
            blurRadius: 36,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0D1432),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 86,
                height: 6,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFF42539C),
                ),
              ),
            ),
            Text(
              'Today',
              style: tt.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            buildTaskItem('UI Design Review', '10:00', const Color(0xFF22D3EE)),
            buildTaskItem('Database Sync Setup', '13:30', const Color(0xFF818CF8)),
            buildTaskItem('Final Presentation', '17:00', const Color(0xFF34D399)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add new task',
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.item,
    required this.textTheme,
  });

  final _FeatureItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111A39).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A4A86).withValues(alpha: 0.58)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
              ),
            ),
            child: Icon(item.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StepItem {
  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.item,
    required this.textTheme,
  });

  final _StepItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111A39).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A4A86).withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              item.number,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PreviewItem {
  const _PreviewItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.item,
    required this.textTheme,
  });

  final _PreviewItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A39).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A4A86).withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2A5A).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF28357A), Color(0xFF1A2554)],
              ),
            ),
            child: Center(
              child: Icon(
                item.icon,
                color: Colors.white.withValues(alpha: 0.88),
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
