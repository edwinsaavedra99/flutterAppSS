import 'package:bloc/bloc.dart';
import '../pages/serviciopage.dart';
import '../pages/infopage.dart';
import '../pages/perfilpage.dart';

enum NavigationEvents {
  ServicioClickedEvent,
  PerfilClickedEvent,
  InfoClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  @override
  NavigationStates get initialState => ServicioPage();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {      
      case NavigationEvents.ServicioClickedEvent:
        yield ServicioPage();
        break;
      case NavigationEvents.PerfilClickedEvent:
        yield PerfilPage();
        break;
      case NavigationEvents.InfoClickedEvent:
        yield InfoPage();
        break;
    }
  }
}