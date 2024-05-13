part of 'create_data_bloc.dart';

abstract class CreateDataState {}

class CreateDataInitial extends CreateDataState {}

class CreateDataLoading extends CreateDataState {}

class CreateDataSuccess extends CreateDataState {
  final data;

  CreateDataSuccess({required this.data});
}

class CreateDataFailed extends CreateDataState {
  final String error;

  CreateDataFailed({required this.error});
}
