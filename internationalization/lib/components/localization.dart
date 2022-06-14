
import 'package:bytebank/components/error.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../http/webclients/I18NWebClient.dart';
import 'container.dart';


@immutable
abstract class I18NMessagesState {
  const I18NMessagesState();
}

@immutable
class LoadingI18NMessagesState extends I18NMessagesState {
  const LoadingI18NMessagesState();
}

@immutable
class InitI18NMessagesState extends I18NMessagesState {
  const InitI18NMessagesState();
}

@immutable
class LoadedI18NMessagesState extends I18NMessagesState {
  final I18NMessages messages;

  const LoadedI18NMessagesState(this.messages);
}

class I18NMessages {
  final Map<String, dynamic> _messages;
  I18NMessages(this._messages);

  String get(String key) {
    assert(key != null);
    assert(_messages.containsKey(key));
    return(_messages[key]);
  }
}

@immutable
class FatalErrorI18NMessagesState extends I18NMessagesState {
  const FatalErrorI18NMessagesState();
}

typedef Widget I18NWidgetCreator(I18NMessages messages);


class I18NLoadingContainer extends BlocContainer {
  I18NWidgetCreator creator;
  String viewKey;
  

  I18NLoadingContainer({
    @required String viewKey,
    @required I18NWidgetCreator creator
  }) {
    creator = this.creator;
    viewKey = this.viewKey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<I18NMessagesCubit>(
      create: (BuildContext context) {
        final cubit = I18NMessagesCubit();
        cubit.reload(I18NWebClient(this.viewKey));
        return cubit;
      },
      child: I18nLoadingView(this.creator),
      );
  }

}


class LocalizationContainer extends BlocContainer {

  Widget child;

  LocalizationContainer({@required Widget this.child});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurrentLocaleCubit>(
      create: (context) => CurrentLocaleCubit(),
      child: this.child,
    );
  }
} 
class CurrentLocaleCubit extends Cubit<String> {
  CurrentLocaleCubit() : super("en");
}


class ViewI18N {
  String _language;

  ViewI18N(BuildContext context) {
    //o problema dessa abordagem é o rebuild quando você troca a língua
    //o que vc quer construir quando troca o currentLocalecubit?
    //em geral é comum reinicializar o sistema ou voltar para a tela inicial
    this._language = BlocProvider.of<CurrentLocaleCubit>(context).state;
  }

  
  String localize(Map<String, String> values) {
    assert (values!=null);
    assert (values.containsKey(_language));

    return values[_language];
  }
}

class I18nLoadingView extends StatelessWidget {

  final I18NWidgetCreator _creator;

  I18nLoadingView(this._creator);


  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<I18NMessagesCubit, I18NMessagesState>(builder: (context, state) {
      if (state is InitI18NMessagesState || state is LoadingI18NMessagesState) {
        return ProgressView(message: "Loading...",);
      }
      if (state is LoadedI18NMessagesState) {
        final messages = state.messages;
        return _creator.call(messages);
      }
      return ErrorView("Erro buscando mensagens da tela");
    });

  }

}

class I18NMessagesCubit extends Cubit<I18NMessagesState> {
  I18NMessagesCubit() : super(InitI18NMessagesState());
  
  reload(I18NWebClient client){

    emit(LoadingI18NMessagesState());

    client.findAll().then((messages) => emit(
      LoadedI18NMessagesState(I18NMessages(messages)),

      ),
    );

  }



}