import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';

part 'get_data_event.dart';
part 'get_data_state.dart';

class GetDataBloc extends Bloc<GetDataEvent, GetDataState> {
  GetDataBloc() : super(GetDataInitial()) {
    on<GetData>((event, emit) async {
      emit(GetDataLoading());
      try {
        Response res = await dio.get('/posts');
        print("Data get ${res.data}");

        if (res.statusCode == 200) {
          emit(GetDataLoaded(data: res.data));
        }
      } catch (e) {
        emit(GetDataFailed(error: e.toString()));
      }
    });
  }
}
