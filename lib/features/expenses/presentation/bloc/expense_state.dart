
part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final double? total;
  
  ExpenseLoaded({required this.expenses, this.total});
  
  @override
  List<Object?> get props => [expenses, total];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  
  ExpenseOperationSuccess({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class ExpenseError extends ExpenseState {
  final String message;
  
  ExpenseError({required this.message});
  
  @override
  List<Object?> get props => [message];
}