//  — search // <name> button|card|drawer item|dashboard card
import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gradient page background used across screens.
class AppPageBackground extends StatelessWidget {
  const AppPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.pageGradient),
      child: child,
    );
  }
}

/// Gradient text for titles and branding.
class AppGradientText extends StatelessWidget {
  const AppGradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppColors.headerGradient,
    this.maxLines = 1,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    //gradient
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );

//color
    // return Text(
    //     text,
    //     style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
    //       color: Colors.white,
    //       fontWeight: FontWeight.w400,
    //     ),
    //     maxLines: maxLines,
    //     overflow: TextOverflow.ellipsis,
      
    // );

  }
}

/// Frosted glass card for login and overlays.
class AppGlassCard extends StatelessWidget {
  // AppGlassCard card
  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.margin,
  }); // end AppGlassCard card

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// White card with soft purple border and shadow.
class AppCard extends StatelessWidget {
  // AppCard card
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
  }); // end AppCard card

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [AppColors.softShadow()],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        child: card,
      ),
    );
  }
}

/// Primary gradient button.
class AppPrimaryButton extends StatelessWidget {
  // AppPrimaryButton button
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.height = 54,
  }); // end AppPrimaryButton button

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final btn = DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
            : AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null ? null : [AppColors.glowShadow()],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Section title with decorative accent bar.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.text, {super.key, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppGradientText(
                  text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard welcome banner with gradient and soft glow.
class AppWelcomeBanner extends StatelessWidget {
  const AppWelcomeBanner({
    super.key,
    required this.greeting,
    required this.name,
    required this.email,
    required this.phone,
    this.compact = false,
  });

  final String greeting;
  final String name;
  final String email;
  final String phone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 16.0 : 24.0;
    final avatar = compact ? 56.0 : 76.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: AppColors.welcomeGradient,
        borderRadius: BorderRadius.circular(compact ? 22 : 28),
        boxShadow: [AppColors.glowShadow(AppColors.primaryDeep)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 8 : 12),
                AppInfoRow(icon: Icons.email_rounded, text: email),
                const SizedBox(height: 4),
                AppInfoRow(icon: Icons.phone_rounded, text: phone),
              ],
            ),
          ),
          SizedBox(width: compact ? 10 : 16),
          Container(
            width: avatar,
            height: avatar,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.12),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: compact ? 28 : 38,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick-action tile for dashboard grids.
class AppActionTile extends StatelessWidget {
  // AppActionTile card
  const AppActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.compact = false,
  }); // end AppActionTile card

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 44.0;
    final glyphSize = compact ? 18.0 : 22.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: color.withValues(alpha: 0.12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 10,
              vertical: compact ? 8 : 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.65)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: glyphSize),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 2 : 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: compact ? 8 : 9,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Styled menu button for app bars.
class AppMenuButton extends StatelessWidget {
  // AppMenuButton button
  const AppMenuButton({super.key, required this.onPressed, this.compact = false}); // end AppMenuButton button

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: compact ? 40 : 48,
        minHeight: compact ? 40 : 48,
      ),
      onPressed: onPressed,
      icon: Container(
        padding: EdgeInsets.all(compact ? 6 : 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDeep.withValues(alpha: 0.12),
              AppColors.primary.withValues(alpha: 0.08),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.menu_rounded,
          color: AppColors.primaryDeep,
          size: compact ? 22 : 24,
        ),
      ),
    );
  }
}

/// Pretty bottom nav wrapper with soft top border and shadow.
class AppBottomNavShell extends StatelessWidget {
  const AppBottomNavShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.navBarGradient,
        border: const Border(top: BorderSide(color: AppColors.borderSoft)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Narrow phones (~74.7 mm / 360–412 logical px).
bool isNarrowPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width <= 412;

/// Extra-tight layouts (≈360 px and below).
bool isCompactPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width <= 380;

/// Very narrow (~73 mm width, ≤360 logical px).
bool isMicroPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width <= 360;

/// Short screens (~160 mm height, ≤720 logical px).
bool isShortPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).height <= 720;

/// Horizontal padding that keeps content inside narrow screens.
double pageHorizontalPadding(BuildContext context) {
  if (isMicroPhone(context)) return 8.0;
  if (isCompactPhone(context)) return 10.0;
  if (isNarrowPhone(context)) return 12.0;
  return 20.0;
}

/// Auth screens (login / register) — scales spacing for ~73×160 mm phones.
double authHorizontalPadding(BuildContext context) {
  if (isMicroPhone(context)) return 12.0;
  if (isCompactPhone(context)) return 14.0;
  if (isNarrowPhone(context)) return 16.0;
  return 24.0;
}

double authEmblemSize(BuildContext context) {
  if (isMicroPhone(context)) return 72.0;
  if (isCompactPhone(context)) return 84.0;
  if (isNarrowPhone(context)) return 96.0;
  return 112.0;
}

/// Max width for dialogs and sheets on small screens.
double dialogMaxWidth(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w > 600 ? 560 : w * 0.92;
}

/// Clamps system text scaling so layouts stay stable on small phones.
class AppResponsiveScope extends StatelessWidget {
  const AppResponsiveScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final micro = mq.size.width <= 360;
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(
          minScaleFactor: micro ? 0.82 : 0.85,
          maxScaleFactor: 1.0,
        ),
      ),
      child: child,
    );
  }
}

/// Label / value row that never overflows horizontally.
class AppLabelValueRow extends StatelessWidget {
  const AppLabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.gap = 8,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: gap),
        Flexible(
          child: Text(
            value,
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Three-column stats strip for product/dashboard summaries.
class AppStatColumn extends StatelessWidget {
  const AppStatColumn({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: compact ? 18 : 22),
        SizedBox(height: compact ? 4 : 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: compact ? 1 : 2),
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 9 : 11,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Vertical divider used between stat columns.
class AppStatDivider extends StatelessWidget {
  const AppStatDivider({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}

/// Safe label row — prevents horizontal overflow.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = AppColors.accentLight,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
