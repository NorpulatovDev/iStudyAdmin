import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  Future<void> saveToken(String key, String token)async{
    await _storage.write(key: key, value: token);
  }

  Future<String?> getToken(String key)async{
    return await _storage.read(key: key);
  }

  Future<void> deleteToken(String key)async{
    await _storage.delete(key: key);
  }

  Future<void> clearAll()async{
    await _storage.deleteAll();
  }

  Future<void> saveUserData(String userData)async{
    await _storage.write(key: ApiConstants.userDataKey, value: userData);
  }

  Future<String?> getUserData()async{
    return await _storage.read(key: ApiConstants.userDataKey);
  }
}