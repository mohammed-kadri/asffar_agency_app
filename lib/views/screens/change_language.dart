import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import 'package:untitled3/providers/locale_provider.dart';

class ChangeLanguage extends StatefulWidget {
  ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  void _changeLanguage(Locale locale) async {
    final currentLocale =
        Provider.of<LocaleProvider>(context, listen: false).locale;
    if (currentLocale != locale) {
      await Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(locale);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content:
              Text(AppLocalizations.of(context)!.translate('languageChanged'),
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                fontWeight: FontWeight.w600
              ),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Color(0xFF313131).withOpacity(0.1),
              height: 1,
            )),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.translate('changeLanguage'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        leading: IconButton(
          padding: const EdgeInsets.only(left: 12),
          splashRadius: 24,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 22,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: InkWell(
              onTap: () => _changeLanguage(Locale('ar', '')),
              hoverColor: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                          image: AssetImage('assets/images/algeria.png'),
                          height: 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "العربية",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF313131).withAlpha(200),
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black.withAlpha(20), height: 0),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: InkWell(
              onTap: () => _changeLanguage(Locale('fr', '')),
              hoverColor: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                          image: AssetImage('assets/images/france.png'),
                          height: 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "Francais",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF313131).withAlpha(200),
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black.withAlpha(20), height: 0),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: InkWell(
              onTap: () => _changeLanguage(Locale('en', '')),
              hoverColor: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                          image: AssetImage('assets/images/united-kingdom.png'),
                          height: 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "English",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF313131).withAlpha(200),
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black.withAlpha(20), height: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
