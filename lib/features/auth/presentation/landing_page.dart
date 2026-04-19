import 'dart:async';
import 'dart:ui'; // Needed for ImageFilter

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey _featuresKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  void _openApp() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _scrollToFeatures() async {
    final sectionContext = _featuresKey.currentContext;
    if (sectionContext == null) return;

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      alignment: 0.06,
    );
  }

  TextTheme _landingTextTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 64,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: Colors.white,
        letterSpacing: -1.5,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF64748B),
        height: 1.6,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTopNav(TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'UniTask',
            style: tt.titleMedium,
          ),
          const Spacer(),
          _HoverButton(
            onPressed: _openApp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Open App', style: tt.titleSmall),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(TextTheme tt, bool compact) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFF14B8A6), size: 18),
              const SizedBox(width: 8),
              Text(
                'Next-Gen Productivity',
                style: tt.bodyMedium?.copyWith(
                  color: const Color(0xFF14B8A6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Manage your tasks\nsmarter and faster.',
          style: tt.headlineLarge?.copyWith(fontSize: compact ? 48 : 64),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(
            'Organize assignments, track progress, and stay on schedule with a beautiful SaaS workflow.',
            style: tt.bodyLarge,
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _HoverButton(
              onPressed: _openApp,
              scaleAmount: 0.96,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Start Now', style: tt.titleMedium),
                    const SizedBox(width: 8),
                    const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
            _HoverButton(
              onPressed: _scrollToFeatures,
              scaleAmount: 0.96,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Learn More', style: tt.titleMedium),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_downward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 48),
          Center(
            child: _FloatingAnimation(
              child: _PhoneMock(textTheme: tt),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: content),
        const SizedBox(width: 40),
        const Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: _FloatingAnimation(
              child: _PhoneMock(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required TextTheme tt,
    bool center = false,
  }) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.headlineMedium?.copyWith(fontSize: 40), textAlign: center ? TextAlign.center : TextAlign.start),
        const SizedBox(height: 12),
        Text(subtitle, style: tt.bodyLarge, textAlign: center ? TextAlign.center : TextAlign.start),
      ],
    );
  }

  Widget _buildFeatures(TextTheme tt) {
    const features = [
      _FeatureItem(icon: Icons.task_alt_rounded, title: 'Task Management', description: 'Create and organize assignments efficiently.'),
      _FeatureItem(icon: Icons.sync_rounded, title: 'Real-time Sync', description: 'Instant updates across all your devices.'),
      _FeatureItem(icon: Icons.notifications_active_rounded, title: 'Smart Reminders', description: 'Never miss a deadline with intelligent alerts.'),
      _FeatureItem(icon: Icons.auto_awesome_rounded, title: 'Premium UI', description: 'Focus better with a clean, modern interface.'),
    ];

    return Container(
      key: _featuresKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSectionHeader(
            title: 'Everything you need',
            subtitle: 'Powerful features designed for maximum productivity.',
            tt: tt,
            center: true,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = width >= 1080 ? (width - 48) / 4 : width >= 760 ? (width - 16) / 2 : width;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: features.map((feature) {
                  return SizedBox(
                    width: cardWidth,
                    child: _HoverCard(
                      child: _FeatureCard(item: feature, textTheme: tt),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShowcase(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(
          title: 'Beautiful inside out',
          subtitle: 'Experience an app that feels as good as it looks.',
          tt: tt,
          center: true,
        ),
        const SizedBox(height: 48),
        SizedBox(
          height: 500,
          child: PageView(
            controller: PageController(viewportFraction: 0.8),
            children: [
              _HoverCard(scaleAmount: 0.98, child: const _PhoneMock(title: 'Dashboard Overview')),
              _HoverCard(scaleAmount: 0.98, child: const _PhoneMock(title: 'Assignment Board')),
              _HoverCard(scaleAmount: 0.98, child: const _PhoneMock(title: 'Focus Mode')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaq(TextTheme tt) {
    const faqs = [
      _FaqItem(question: 'Is this app free?', answer: 'Yes. UniTask core features are free to use.'),
      _FaqItem(question: 'Does it sync across devices?', answer: 'Yes. Data synchronizes in real-time across all devices.'),
      _FaqItem(question: 'Can I use it offline?', answer: 'Yes. You can work offline and sync automatically when online.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(
          title: 'Common Questions',
          subtitle: 'Everything you need to know about UniTask.',
          tt: tt,
          center: true,
        ),
        const SizedBox(height: 48),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: faqs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: const Color(0xFF3B82F6),
                          collapsedIconColor: const Color(0xFF94A3B8),
                          title: Text(item.question, style: tt.titleMedium?.copyWith(fontSize: 18)),
                          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(item.answer, style: tt.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                      if (index != faqs.length - 1)
                        Divider(height: 1, color: const Color(0xFF334155).withOpacity(0.5)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA(TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: -10,
          )
        ]
      ),
      child: Column(
        children: [
          Text(
            'Ready to boost your productivity?',
            style: tt.headlineMedium?.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of users organizing their tasks efficiently.',
            style: tt.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _HoverButton(
            onPressed: _openApp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Start Now', style: tt.titleMedium?.copyWith(fontSize: 20)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
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
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background effects using ImageFilter directly inside a BackdropFilter, or simplified glow
          Positioned(
            top: -200,
            left: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            top: 400,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF14B8A6).withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FadeInSection(delayMs: 0, child: _buildTopNav(tt)),
                      const SizedBox(height: 64),
                      _FadeInSection(delayMs: 100, child: _buildHero(tt, compact)),
                      const SizedBox(height: 120),
                      _FadeInSection(delayMs: 200, child: _buildFeatures(tt)),
                      const SizedBox(height: 120),
                      _FadeInSection(delayMs: 300, child: _buildShowcase(tt)),
                      const SizedBox(height: 120),
                      _FadeInSection(delayMs: 400, child: _buildFaq(tt)),
                      const SizedBox(height: 120),
                      _FadeInSection(delayMs: 500, child: _buildBottomCTA(tt)),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ANIMATION HELPERS

class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.child, required this.onPressed, this.scaleAmount = 0.97});
  final Widget child;
  final VoidCallback onPressed;
  final double scaleAmount;
  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovering = false;
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressing ? widget.scaleAmount : (_hovering ? 1.02 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) => setState(() => _pressing = false),
        onTapCancel: () => setState(() => _pressing = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child, this.scaleAmount = 1.03});
  final Widget child;
  final double scaleAmount;
  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? widget.scaleAmount : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _FloatingAnimation extends StatefulWidget {
  const _FloatingAnimation({required this.child});
  final Widget child;
  @override
  State<_FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<_FloatingAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final Animation<Offset> _animation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 0.05),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

class _FadeInSection extends StatefulWidget {
  const _FadeInSection({required this.child, required this.delayMs});
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
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// DATA CLASSES & UI COMPONENTS

class _FeatureItem {
  const _FeatureItem({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item, required this.textTheme});
  final _FeatureItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: const Color(0xFF3B82F6), size: 32),
          ),
          const SizedBox(height: 24),
          Text(item.title, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(item.description, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class _PhoneMock extends StatelessWidget {
  const _PhoneMock({this.textTheme, this.title = 'Today'});
  final TextTheme? textTheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = textTheme ?? GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme);

    Widget buildTaskItem(String taskTitle, String time, Color dotColor) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF334155).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF475569).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 14),
            Expanded(child: Text(taskTitle, style: tt.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600))),
            Text(time, style: tt.bodySmall?.copyWith(color: const Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF334155), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 60, height: 6, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFF334155)))),
            Text(title, style: tt.titleMedium?.copyWith(fontSize: 24)),
            const SizedBox(height: 24),
            buildTaskItem('Design Review', '10:00', const Color(0xFF14B8A6)),
            buildTaskItem('Development', '13:00', const Color(0xFF3B82F6)),
            buildTaskItem('Sync Team', '16:30', const Color(0xFF8B5CF6)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)]), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('New Task', style: tt.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
