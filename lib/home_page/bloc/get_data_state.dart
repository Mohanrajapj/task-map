part of 'get_data_bloc.dart';

abstract class GetDataState {}

class GetDataInitial extends GetDataState {}

class GetDataLoading extends GetDataState {}

class GetDataLoaded extends GetDataState {
  final List data;

  GetDataLoaded({required this.data});
}

class GetDataFailed extends GetDataState {
  final String error;

  GetDataFailed({required this.error});
}
