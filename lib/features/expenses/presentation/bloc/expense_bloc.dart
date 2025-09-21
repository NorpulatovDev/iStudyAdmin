import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseBloc(this._repository) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadMonthlyExpenses>(_onLoadMonthlyExpenses);
    on<LoadDailyExpenses>(_onLoadDailyExpenses);
    on<CreateExpense>(_onCreateExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
      LoadExpenses event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());
      final expenses = await _repository.getExpensesByBranch();
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyExpenses(
      LoadMonthlyExpenses event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());
      final expenses = await _repository.getExpensesByMonth(
        year: event.year,
        month: event.month,
      );
      final total = await _repository.getMonthlyExpensesTotal(
        year: event.year,
        month: event.month,
      );
      emit(ExpenseLoaded(expenses: expenses, total: total));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadDailyExpenses(
      LoadDailyExpenses event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());
      final expenses = await _repository.getExpensesByDate(date: event.date);
      final total = await _repository.getDailyExpensesTotal(date: event.date);
      emit(ExpenseLoaded(expenses: expenses, total: total));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onCreateExpense(
      CreateExpense event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());
      await _repository.createExpense(
        description: event.description,
        amount: event.amount,
        category: event.category,
      );
      emit(ExpenseOperationSuccess(message: 'Expense created successfully'));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());
      await _repository.updateExpense(
        id: event.id,
        description: event.description,
        amount: event.amount,
        category: event.category,
      );
      emit(ExpenseOperationSuccess(message: 'Expense updated successfully'));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());
      await _repository.deleteExpense(event.id);
      emit(ExpenseOperationSuccess(message: 'Expense deleted successfully'));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }
}
