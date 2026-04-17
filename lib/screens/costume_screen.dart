import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/costume.dart';
import '../providers/costume_provider.dart';

class CostumeScreen extends ConsumerWidget {
  const CostumeScreen({super.key});

  static const _available = [Costume.normal, Costume.carrot, Costume.dress];
  static const _comingSoonCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(costumeProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD6E7),
              Color(0xFFFFF0F8),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildTitle(),
              const SizedBox(height: 6),
              const Text(
                'あなたのウサギをおしゃれに',
                style: TextStyle(
                  color: Color(0xFF9B6DD6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children: [
                      ..._available.map((c) => _CostumeCard(
                            costume: c,
                            isSelected: selected == c,
                            onTap: () => ref.read(costumeProvider.notifier).select(c),
                          )),
                      ...List.generate(
                        _comingSoonCount,
                        (_) => const _ComingSoonCard(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB5D0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0x66FF6E99),
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                    ),
                    child: const Text(
                      'もどる',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.auto_awesome, color: Color(0xFFFFCC00), size: 20),
        SizedBox(width: 10),
        Text(
          'きせかえ',
          style: TextStyle(
            color: Color(0xFF5D3A1A),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        SizedBox(width: 10),
        Icon(Icons.auto_awesome, color: Color(0xFFFFCC00), size: 20),
      ],
    );
  }
}

class _CostumeCard extends StatelessWidget {
  const _CostumeCard({
    required this.costume,
    required this.isSelected,
    required this.onTap,
  });

  final Costume costume;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFFFF0F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFFFCCDD),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withAlpha(80),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Image.asset(
                  costume.previewImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.pets,
                    size: 60,
                    color: isSelected ? const Color(0xFF9B6DD6) : const Color(0xFFCCAADD),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                    ),
                  Text(
                    costume.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF5D3A1A) : const Color(0xFF9B6DD6),
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

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEECCDD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 40,
            color: const Color(0xFFCCAACC).withAlpha(180),
          ),
          const SizedBox(height: 12),
          const Text(
            'Coming soon',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBB99BB),
            ),
          ),
        ],
      ),
    );
  }
}
