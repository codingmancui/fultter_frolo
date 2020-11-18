import 'dart:collection';

import 'package:frolo/blocs/bloc_provider.dart';
import 'package:frolo/data/protocol/models.dart';
import 'package:frolo/data/repository/wan_repository.dart';
import 'package:frolo/utils/log_util.dart';
import 'package:frolo/utils/object_util.dart';
import 'package:rxdart/subjects.dart';
import 'package:sp_util/sp_util.dart';

class SearchBloc implements BlocBase {
  static const String LOCAL_HOT_TAG = 'local_hot_tag';
  WanRepository _wanRepository = new WanRepository();

  BehaviorSubject<List<SearchTagModel>> _netTagsSubject = BehaviorSubject();

  Sink<List<SearchTagModel>> get netTagsSink => _netTagsSubject.sink;

  Stream<List<SearchTagModel>> get netTagsStream => _netTagsSubject.stream;

  BehaviorSubject<List<String>> _localTagsSubject = BehaviorSubject();

  Sink<List<String>> get localTagsSink => _localTagsSubject.sink;

  Stream<List<String>> get localTagsStream => _localTagsSubject.stream;

  List<String> _localTags;

  Future getNetHotTag() {
    return _wanRepository.getSearchHotTag().then((list) {
      LogUtil.v('getHotTag list size ${list.length}', tag: 'SearchBloc');
      netTagsSink.add(UnmodifiableListView<SearchTagModel>(list));
    }).catchError((e) {
      LogUtil.v('getHotTag list on error', tag: 'SearchBloc');
    });
  }

  Future getLocalHotTag() async {
    _localTags = await SpUtil.getStringList(LOCAL_HOT_TAG);
    localTagsSink.add(UnmodifiableListView<String>(_localTags));
    LogUtil.v('getLocalHotTag values is  $_localTags', tag: 'SearchBloc');
  }

  void saveLocalTag(String key) async {
    if (ObjectUtil.isEmptyList(_localTags)) {
      _localTags = new List<String>();
    }
    if (_localTags.contains(key)) {
      _localTags.remove(key);
    }
    _localTags.insert(0, key);
    SpUtil.putStringList(LOCAL_HOT_TAG, _localTags).then((value) {
      if (value) {
        localTagsSink.add(UnmodifiableListView<String>(_localTags));
      }
    });
  }

  void clearLocalTags() {
    _localTags.clear();
    SpUtil.putStringList(LOCAL_HOT_TAG, _localTags);
    localTagsSink.add(UnmodifiableListView<String>(_localTags));
  }

  @override
  void dispose() {
    _netTagsSubject.close();
    _localTagsSubject.close();
  }

  @override
  Future getData({String labelId, int page}) async {
    getLocalHotTag();
    return getNetHotTag();
  }

  @override
  Future onLoadMore({String labelId}) {
    return null;
  }

  @override
  Future onRefresh({String labelId}) {
    return null;
  }
}
