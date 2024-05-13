import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../main.dart';

part 'create_data_event.dart';
part 'create_data_state.dart';

class CreateDataBloc extends Bloc<CreateDataEvent, CreateDataState> {
  CreateDataBloc() : super(CreateDataInitial()) {
    on<CreateData>((event, emit) async {
      emit(CreateDataLoading());
      try {
        Response res = await dio.post('/posts', data: event.body);
        print("Data create ${res.statusCode}");
        if (res.statusCode == 200 || res.statusCode == 201) {
          emit(CreateDataSuccess(data: res.data));
        }
      } catch (e) {
        emit(CreateDataFailed(error: e.toString()));
      }
    });
  }
}
