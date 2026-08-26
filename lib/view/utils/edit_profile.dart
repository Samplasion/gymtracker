import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/utils/crop_image.dart';
import 'package:gymtracker/view/utils/social.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final String userID;

  const EditProfilePage({super.key, required this.userID});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _initialized = false;
  bool _saving = false;
  Uint8List? _pendingAvatarBytes;
  bool _removeAvatarPending = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFile(type: FileType.image);

      if (result != null) {
        final file = result.xFile;
        Uint8List? bytes = await file.readAsBytes();

        if (!mounted) return;
        final cropped = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (context) => CropImagePage(imageBytes: bytes),
          ),
        );

        if (cropped != null) {
          setState(() {
            _pendingAvatarBytes = cropped;
            _removeAvatarPending = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("userProfile.edit.error".t)));
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(GTIcons.gallery),
                title: Text("userProfile.edit.changePicture".t),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(GTIcons.delete, color: Colors.red),
                title: Text(
                  "userProfile.edit.removePicture".t,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _pendingAvatarBytes = null;
                    _removeAvatarPending = true;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final onlineNotifier = ref.read(onlineProvider.notifier);
      final newName = _nameController.text.trim();
      final finalName = newName.isEmpty ? null : newName;

      // Update full name
      await onlineNotifier.updateProfile(fullName: finalName);

      // Update avatar
      if (_removeAvatarPending) {
        await onlineNotifier.removeAvatar();
      } else if (_pendingAvatarBytes != null) {
        await onlineNotifier.uploadAvatar(_pendingAvatarBytes!);
      }

      // Invalidate the relevant providers
      ref.invalidate(friendPublicDataProvider(widget.userID));
      ref.invalidate(friendProvider);

      if (mounted) {
        Go.snack("userProfile.edit.success".t);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Go.snack("userProfile.edit.error".t);
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(friendPublicDataProvider(widget.userID));

    if (!_initialized && profileAsync.hasValue) {
      final profile = profileAsync.value!;
      _nameController.text = profile.friend.fullName ?? "";
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("userProfile.edit.title".t),
        actions: [
          if (!_saving)
            IconButton(
              icon: const Icon(GTIcons.done),
              tooltip: "userProfile.edit.done".t,
              onPressed: _save,
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: GBLoadingIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (profile) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _showImageOptions,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _buildAvatarPreview(profile.friend.id),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    GTIcons.edit,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showImageOptions,
                          child: Text("userProfile.edit.changePicture".t),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "userProfile.edit.fullName".t,
                            hintText: "userProfile.edit.fullNameHint".t,
                            prefixIcon: const Icon(GTIcons.profile),
                            suffixIcon: _nameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(GTIcons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _nameController.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (val) => setState(() {}),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _save(),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: const Icon(GTIcons.done),
                            label: Text("userProfile.edit.done".t),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_saving)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(child: GBLoadingIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(String userId) {
    if (_removeAvatarPending) {
      return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.person, size: 64),
      );
    }

    if (_pendingAvatarBytes != null) {
      return Image.memory(_pendingAvatarBytes!, fit: BoxFit.cover);
    }

    return UserAccountIcon(id: userId, radius: 64);
  }
}
