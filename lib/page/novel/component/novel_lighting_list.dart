/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/component/novel_lighting_store.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NovelLightingList extends StatefulWidget {
  final FutureGet futureGet;

  const NovelLightingList({Key key, this.futureGet}) : super(key: key);
  @override
  _NovelLightingListState createState() => _NovelLightingListState();
}

class _NovelLightingListState extends State<NovelLightingList> {
  RefreshController _easyRefreshController;
  NovelLightingStore _store;
  @override
  void initState() {
    _easyRefreshController = RefreshController(initialRefresh: true);
    _store = NovelLightingStore(widget.futureGet, _easyRefreshController);
    super.initState();
  }

  @override
  void didUpdateWidget(NovelLightingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureGet != widget.futureGet) {
      _store.source = widget.futureGet;
      _store.fetch();
    }
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    if (_store.novels.isNotEmpty) {
      return ListView.builder(
        itemBuilder: (context, index) {
          Novel novel = _store.novels[index];
          return ListTile(
            title: Text(novel.title),
            subtitle: Text(
              novel.user.name,
              maxLines: 1,
            ),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (BuildContext context) => NovelViewerPage(
                        id: novel.id,
                        novel: novel,
                      )));
            },
            trailing: NovelBookmarkButton(novel: novel),
          );
        },
        itemCount: _store.novels.length,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return SmartRefresher(
        onLoading: () => _store.next(),
        onRefresh: () => _store.fetch(),
        enablePullDown: true,
        enablePullUp: true,
        controller: _easyRefreshController,
        child: _buildBody(context),
      );
    });
  }
}
