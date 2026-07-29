// lib/widgets/jobs_shimmer.dart
//
// A shimmer skeleton that structurally mirrors JobCard. Shown in the loading
// arm of _JobList instead of a plain CircularProgressIndicator, so the user
// sees a preview of the card layout while jobs are being fetched. Each
// _ShimmerCard matches the rough dimensions and structure of the real card:
// a title bar, a company/location line, and a row of two pill-shaped chips.
//
// Shimmer.fromColors sweeps a gradient over all white child containers using
// ShaderMask. The base and highlight colours adapt to light and dark mode so
// the skeleton always looks intentional, not broken.
//
// No provider imports — this is pure presentational UI with no state.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JobsShimmer extends StatelessWidget {
  const JobsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Choose colours based on the current brightness so the skeleton looks
    // correct in both light and dark mode without any hardcoded hex values.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      // Six placeholder cards fills a typical phone screen without scrolling,
      // giving the impression of a full list being loaded.
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (_, __) => const _ShimmerCard(),
      ),
    );
  }
}

// A const placeholder that mirrors the visual structure of a real JobCard.
// All containers use Colors.white as their colour — Shimmer.fromColors applies
// a ShaderMask over the entire subtree and turns white into the gradient.
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title line — wider bar representing the job title text.
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),

            // Company name line — slightly shorter and thinner.
            Container(
              height: 12,
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),

            // Location line — shortest text line.
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),

            // Two pill-shaped chips representing salary and employment type.
            Row(
              children: [
                Container(
                  height: 28,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 28,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
