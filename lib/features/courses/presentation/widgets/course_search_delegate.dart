import 'package:flutter/material.dart';
import '../../data/models/course_model.dart';

class CourseSearchDelegate extends SearchDelegate<CourseModel?> {
  final List<CourseModel> courses;

  CourseSearchDelegate(this.courses);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredCourses = courses.where((course) {
      final searchLower = query.toLowerCase();
      return course.name.toLowerCase().contains(searchLower) ||
             (course.description?.toLowerCase().contains(searchLower) ?? false) ||
             course.branchName.toLowerCase().contains(searchLower);
    }).toList();

    if (filteredCourses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No courses found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              course.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            course.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\${course.price.toStringAsFixed(2)}'),
              Text(
                course.branchName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: course.durationMonths != null
              ? Chip(
                  label: Text('${course.durationMonths}m'),
                  backgroundColor: Colors.blue[100],
                )
              : null,
          onTap: () {
            close(context, course);
          },
        );
      },
    );
  }
}