import 'package:url_launcher/url_launcher.dart';

/// Telefon qo'ng'iroq qilish xizmati
/// 
/// OFFLINE ishlaydi - Internet kerak emas!
/// Telefon orqali to'g'ridan-to'g'ri qo'ng'iroq qiladi
class PhoneService {
  static final PhoneService _instance = PhoneService._internal();
  factory PhoneService() => _instance;
  PhoneService._internal();

  /// Telefon qilish
  /// 
  /// Bu funksiya OFFLINE ishlaydi!
  /// Telefon raqamga to'g'ridan-to'g'ri qo'ng'iroq ochadi
  /// 
  /// Misol: +998901234567
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // Telefon raqamni tozalash
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      
      if (!_isValidPhoneNumber(cleanNumber)) {
        throw Exception('Noto\'g\'ri telefon raqam formati');
      }

      // tel:// protokol orqali qo'ng'iroq
      final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);
      
      if (await canLaunchUrl(telUri)) {
        return await launchUrl(telUri);
      } else {
        throw Exception('Telefon ilovasini ochib bo\'lmadi');
      }
    } catch (e) {
      print('Phone call error: $e');
      return false;
    }
  }

  /// SMS yuborish (ixtiyoriy)
  Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: message != null ? {'body': message} : null,
      );
      
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
      return false;
    } catch (e) {
      print('SMS error: $e');
      return false;
    }
  }

  /// Telefon raqamni formatlash (O'zbekiston formati)
  /// +998901234567 => +998 90 123 45 67
  String formatPhoneNumber(String phoneNumber) {
    final clean = _cleanPhoneNumber(phoneNumber);
    
    if (clean.startsWith('+998') && clean.length == 13) {
      // +998901234567 => +998 90 123 45 67
      return '+998 ${clean.substring(4, 6)} ${clean.substring(6, 9)} ${clean.substring(9, 11)} ${clean.substring(11, 13)}';
    }
    
    return phoneNumber;
  }

  /// Telefon raqamni tozalash (faqat raqamlar va +)
  String _cleanPhoneNumber(String phoneNumber) {
    // Barcha bo'sh joylar, tire va qavslarni olib tashlash
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Agar + bo'lmasa va 998 bilan boshlansa, + qo'shish
    if (!cleaned.startsWith('+') && cleaned.startsWith('998')) {
      cleaned = '+$cleaned';
    }
    
    // Agar 9 bilan boshlansa (masalan: 901234567), +998 qo'shish
    if (cleaned.length == 9 && cleaned.startsWith('9')) {
      cleaned = '+998$cleaned';
    }
    
    return cleaned;
  }

  /// Telefon raqam validatsiyasi (O'zbekiston formati)
  bool _isValidPhoneNumber(String phoneNumber) {
    // O'zbekiston formati: +998XXXXXXXXX (13 belgi)
    final uzbekPhoneRegex = RegExp(r'^\+998[0-9]{9}$');
    return uzbekPhoneRegex.hasMatch(phoneNumber);
  }

  /// Ikki telefon raqam bo'lsa, tanlash dialogini ko'rsatish
  Future<bool> showPhoneCallDialog({
    required BuildContext context,
    required String primaryPhone,
    String? secondaryPhone,
    required String placeName,
  }) async {
    if (secondaryPhone == null || secondaryPhone.isEmpty) {
      // Faqat bitta telefon bo'lsa, to'g'ridan-to'g'ri qo'ng'iroq qilish
      return await makePhoneCall(primaryPhone);
    }

    // Ikki telefon bo'lsa, dialog ko'rsatish
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Qaysi raqamga qo\'ng\'iroq qilasiz?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(placeName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text(formatPhoneNumber(primaryPhone)),
                subtitle: const Text('Asosiy raqam'),
                onTap: () => Navigator.pop(context, primaryPhone),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(formatPhoneNumber(secondaryPhone)),
                subtitle: const Text('Qo\'shimcha raqam'),
                onTap: () => Navigator.pop(context, secondaryPhone),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      return await makePhoneCall(selected);
    }

    return false;
  }
}
