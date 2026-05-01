import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unipay/core/constants/app_colors.dart';
import 'package:unipay/presentation/screens/caissiere_dashboard.dart';
import 'package:unipay/presentation/state/fiche_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration du thème avec Google Fonts (Inter)
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return MultiProvider(
      providers: [
        // Provider pour la gestion des fiches d'engagement
        ChangeNotifierProvider(create: (_) => FicheEngagementNotifier()),
        // Provider pour le formulaire d'encaissement
        ChangeNotifierProvider(create: (_) => FormulaireEncaissementNotifier()),
      ],
      child: MaterialApp(
        title: 'UniPay - Gestion des Paiements Universitaires',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Couleur primaire
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: AppColors.backgroundColor,

          // Schéma de couleur
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            secondary: AppColors.secondaryColor,
            tertiary: AppColors.successColor,
            error: AppColors.errorColor,
            surface: AppColors.surfaceColor,
            background: AppColors.backgroundColor,
          ),

          // Typographie
          textTheme: textTheme.copyWith(
            // Titre très grand
            displayLarge: textTheme.displayLarge?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: textTheme.displayMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: textTheme.displaySmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),

            // Titres
            headlineLarge: textTheme.headlineLarge?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: textTheme.headlineMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),

            // Titres moyens
            titleLarge: textTheme.titleLarge?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            titleMedium: textTheme.titleMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            titleSmall: textTheme.titleSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),

            // Corps de texte
            bodyLarge: textTheme.bodyLarge?.copyWith(
              color: AppColors.textDark,
              fontSize: 16,
            ),
            bodyMedium: textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark,
              fontSize: 14,
            ),
            bodySmall: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),

            // Étiquettes
            labelLarge: textTheme.labelLarge?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            labelMedium: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            labelSmall: textTheme.labelSmall?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),

          // AppBar Theme
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Boutons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          // Champs de texte
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            labelStyle: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: GoogleFonts.inter(color: AppColors.textLight),
            errorStyle: GoogleFonts.inter(
              color: AppColors.errorColor,
              fontSize: 12,
            ),
            helperStyle: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            prefixIconColor: AppColors.textSecondary,
            suffixIconColor: AppColors.textSecondary,
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: AppColors.surfaceColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderColor, width: 1),
            ),
          ),

          // Divider
          dividerTheme: const DividerThemeData(
            color: AppColors.dividerColor,
            thickness: 1,
            space: 16,
          ),

          // Snackbar
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.primaryColor,
            contentTextStyle: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Slider
          sliderTheme: const SliderThemeData(
            activeTrackColor: AppColors.primaryColor,
            inactiveTrackColor: AppColors.backgroundColor,
            thumbColor: AppColors.primaryColor,
            valueIndicatorColor: AppColors.primaryColor,
          ),
        ),
        home: const CaissiereDashboard(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
