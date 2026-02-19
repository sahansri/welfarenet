/* 
RESPONSIVE DESIGN - BEFORE & AFTER EXAMPLES
This file shows practical examples of converting non-responsive code to responsive code

============================================================================
EXAMPLE 1: Simple Text Widget
============================================================================

❌ BEFORE - Hardcoded font sizes:

Text(
  'Welcome to WelfareNet',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.purple,
  ),
)

✅ AFTER - Responsive text style:

Text(
  'Welcome to WelfareNet',
  style: context.textStyles.headline2.copyWith(color: Colors.purple),
)

============================================================================
EXAMPLE 2: Container with Padding and Border Radius
============================================================================

❌ BEFORE - Hardcoded dimensions:

Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
  ),
  child: Text('Content', style: TextStyle(fontSize: 14)),
)

✅ AFTER - Responsive dimensions:

Container(
  padding: EdgeInsets.all(context.responsive.spacing(16)),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(context.responsive.cardBorderRadius),
    color: Colors.white,
  ),
  child: Text('Content', style: context.textStyles.body2),
)

============================================================================
EXAMPLE 3: Icon with Container
============================================================================

❌ BEFORE - Hardcoded sizes:

Container(
  width: 48,
  height: 48,
  decoration: BoxDecoration(
    color: Colors.purple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(Icons.person, size: 24, color: Colors.purple),
)

✅ AFTER - Responsive sizes:

final containerSize = context.responsive.iconSize(48);
Container(
  width: containerSize,
  height: containerSize,
  decoration: BoxDecoration(
    color: Colors.purple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(context.responsive.spacing(12)),
  ),
  child: Icon(
    Icons.person,
    size: context.responsive.iconSize(24),
    color: Colors.purple,
  ),
)


============================================================================
EXAMPLE 4: List Item with Leading Icon
============================================================================

❌ BEFORE - Hardcoded styles:

ListTile(
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  leading: Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Color(0xFF7A5AF8).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.settings, color: Color(0xFF7A5AF8), size: 24),
  ),
  title: Text(
    'Settings',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
  subtitle: Text(
    'Manage your preferences',
    style: TextStyle(fontSize: 14, color: Colors.grey),
  ),
  trailing: Icon(Icons.chevron_right, size: 24),
)

✅ AFTER - Responsive styles:

final responsive = context.responsive;
final textStyles = context.textStyles;
final iconContainerSize = responsive.iconSize(48);

ListTile(
  contentPadding: EdgeInsets.symmetric(
    horizontal: responsive.spacing(16),
    vertical: responsive.spacing(8),
  ),
  leading: Container(
    width: iconContainerSize,
    height: iconContainerSize,
    decoration: BoxDecoration(
      color: Color(0xFF7A5AF8).withOpacity(0.1),
      borderRadius: BorderRadius.circular(responsive.spacing(12)),
    ),
    child: Icon(
      Icons.settings,
      color: Color(0xFF7A5AF8),
      size: responsive.iconSize(24),
    ),
  ),
  title: Text(
    'Settings',
    style: textStyles.subtitle  2,
  ),
  subtitle: Text(
    'Manage your preferences',
    style: textStyles.body2.copyWith(color: Colors.grey),
  ),
  trailing: Icon(
    Icons.chevron_right,
    size: responsive.iconSize(24),
  ),
)

============================================================================
EXAMPLE 5: Card with Header and Content
============================================================================

❌ BEFORE - Multiple hardcoded values:

Card(
  margin: EdgeInsets.all(16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Total amount due',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          '\$150.00',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ],
    ),
  ),
)

✅ AFTER - Fully responsive:

final responsive = context.responsive;
final textStyles = context.textStyles;

Card(
  margin: EdgeInsets.all(responsive.spacing(16)),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
  ),
  child: Padding(
    padding: responsive.cardPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: textStyles.subtitle1,
        ),
        SizedBox(height: responsive.spacing(12)),
        Text(
          'Total amount due',
          style: textStyles.body2.copyWith(color: Colors.grey),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          '\$150.00',
          style: textStyles.headline2.copyWith(color: Colors.purple),
        ),
      ],
    ),
  ),
)

============================================================================
EXAMPLE 6: Button with Custom Sizing
============================================================================

❌ BEFORE - Fixed dimensions:

Container(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    onPressed: () {},
    child: Text(
      'Continue',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
)

✅ AFTER - Responsive dimensions:

Container(
  width: double.infinity,
  height: context.responsive.spacing(54),
  child: ElevatedButton(
    onPressed: () {},
    child: Text(
      'Continue',
      style: context.textStyles.button,
    ),
  ),
)


============================================================================
EXAMPLE 7: Grid with Responsive Layout
============================================================================

❌ BEFORE - Fixed cross axis count:

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemBuilder: (context, index) => Container(),
)

✅ AFTER - Responsive grid:

final responsive = context.responsive;
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: responsive.isSmallScreen ? 2 : (responsive.isMediumScreen ? 3 : 4),
    crossAxisSpacing: responsive.spacing(16),
    mainAxisSpacing: responsive.spacing(16),
  ),
  itemBuilder: (context, index) => Container(),
)

============================================================================
EXAMPLE 8: AppBar with Custom Height
============================================================================

❌ BEFORE - Fixed padding:

AppBar(
  title: Text('Dashboard', style: TextStyle(fontSize: 20)),
  leading: Icon(Icons.menu, size: 24),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 16),
      child: Icon(Icons.notifications, size: 24),
    ),
  ],
)

✅ AFTER - Responsive AppBar:

final responsive = context.responsive;
final textStyles = context.textStyles;

AppBar(
  title: Text('Dashboard', style: textStyles.headline3),
  leading: Icon(Icons.menu, size: responsive.iconSize(24)),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: responsive.spacing(16)),
      child: Icon(
        Icons.notifications,
        size: responsive.iconSize(24),
      ),
    ),
  ],
)

============================================================================
EXAMPLE 9: Dialog with Responsive Content
============================================================================

❌ BEFORE - Hardcoded dialog:

showDialog(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Text(
      'Confirm Action',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    content: Text(
      'Are you sure you want to proceed?',
      style: TextStyle(fontSize: 16),
    ),
    actions: [
      TextButton(
        onPressed: () {},
        child: Text('Cancel', style: TextStyle(fontSize: 14)),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text('Confirm', style: TextStyle(fontSize: 14)),
      ),
    ],
  ),
)

✅ AFTER - Responsive dialog:

final responsive = ResponsiveUtils(context);
final textStyles = AppTextStyles(context);

showDialog(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
    ),
    title: Text(
      'Confirm Action',
      style: textStyles.headline3,
    ),
    content: Text(
      'Are you sure you want to proceed?',
      style: textStyles.body1,
    ),
    actions: [
      TextButton(
        onPressed: () {},
        child: Text('Cancel', style: textStyles.body2),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text('Confirm', style: textStyles.body2),
      ),
    ],
  ),
)

============================================================================
EXAMPLE 10: Full Page Layout
============================================================================

❌ BEFORE - Non-responsive page:

Scaffold(
  body: SafeArea(
    child: ListView(
      padding: EdgeInsets.all(20),
      children: [
        Text(
          'Page Title',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('Content', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    ),
  ),
)

✅ AFTER - Fully responsive page:

Widget build(BuildContext context) {
  final responsive = context.responsive;
  final textStyles = context.textStyles;
  
  return Scaffold(
    body: SafeArea(
      child: ListView(
        padding: responsive.pagePadding,
        children: [
          Text(
            'Page Title',
            style: textStyles.headline2,
          ),
          SizedBox(height: responsive.spacing(16)),
          Container(
            padding: responsive.cardPadding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            ),
            child: Column(
              children: [
                Text('Content', style: textStyles.body1),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

*/
