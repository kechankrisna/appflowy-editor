import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FilePickerResult {
  const FilePickerResult(this.files);

  /// Picked files.
  final List<PlatformFile> files;
}

/// Abstract file picker as a service to implement dependency injection.
abstract class FilePickerService {
  Future<String?> getDirectoryPath({
    String? title,
  }) async =>
      throw UnimplementedError('getDirectoryPath() has not been implemented.');

  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
  }) async =>
      throw UnimplementedError('pickFiles() has not been implemented.');

  Future<String?> saveFile({
    required Uint8List bytes,
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async =>
      throw UnimplementedError('saveFile() has not been implemented.');
}
