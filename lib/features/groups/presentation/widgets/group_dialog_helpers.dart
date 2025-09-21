import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../widgets/edit_group_dialog.dart';
import '../widgets/create_group_dialog.dart';
import '../../data/models/group_model.dart';
import '../../../teachers/presentation/bloc/teacher_bloc.dart';

class GroupDialogHelpers {
  /// Shows the Edit Group Dialog with all necessary BlocProviders
  static void showEditGroupDialog({
    required BuildContext context,
    required GroupModel group,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<GroupBloc>()),
          BlocProvider.value(value: context.read<TeacherBloc>()),
        ],
        child: EditGroupDialog(group: group),
      ),
    );
  }

  /// Shows the Create Group Dialog with all necessary BlocProviders
  static void showCreateGroupDialog({
    required BuildContext context,
    required int courseId,
    required int branchId,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<GroupBloc>()),
          BlocProvider.value(value: context.read<TeacherBloc>()),
        ],
        child: CreateGroupDialog(
          courseId: courseId,
          branchId: branchId,
        ),
      ),
    );
  }

  /// Shows a confirmation dialog for deleting a group
  static void showDeleteConfirmationDialog({
    required BuildContext context,
    required GroupModel group,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Group',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${group.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red[600], size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'This action cannot be undone',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• All students will be removed from this group\n'
                    '• All associated data will be deleted\n'
                    '• Payment records will remain but be unlinked',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete Group'),
          ),
        ],
      ),
    );
  }
}