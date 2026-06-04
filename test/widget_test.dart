import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sift/main.dart';

void main() {
  testWidgets('shows the Clean Byte splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CleanByteApp());

    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
