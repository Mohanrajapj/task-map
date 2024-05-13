part of 'create_data_bloc.dart';

abstract class CreateDataEvent {}

class CreateData extends CreateDataEvent {
  final Map body;

  CreateData({required this.body});
}
