
part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class LoadMonthlyExpenses extends ExpenseEvent {
  final int year;
  final int month;
  
  LoadMonthlyExpenses({required this.year, required this.month});
  
  @override
  List<Object?> get props => [year, month];
}

class LoadDailyExpenses extends ExpenseEvent {
  final DateTime date;
  
  LoadDailyExpenses({required this.date});
  
  @override
  List<Object?> get props => [date];
}

class CreateExpense extends ExpenseEvent {
  final String? description;
  final double amount;
  final ExpenseCategory category;
  
  CreateExpense({
    this.description,
    required this.amount,
    required this.category,
  });
  
  @override
  List<Object?> get props => [description, amount, category];
}

class UpdateExpense extends ExpenseEvent {
  final int id;
  final String? description;
  final double amount;
  final ExpenseCategory category;
  
  UpdateExpense({
    required this.id,
    this.description,
    required this.amount,
    required this.category,
  });
  
  @override
  List<Object?> get props => [id, description, amount, category];
}

class DeleteExpense extends ExpenseEvent {
  final int id;
  
  DeleteExpense({required this.id});
  
  @override
  List<Object?> get props => [id];
}