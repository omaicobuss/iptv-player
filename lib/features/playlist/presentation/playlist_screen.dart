import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/channel.dart';
import 'playlist_provider.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistControllerProvider);
    final query = _searchController.text.trim().toLowerCase();

    final filteredChannels = state.channels.where((channel) {
      if (query.isEmpty) {
        return true;
      }

      final name = channel.name.toLowerCase();
      final group = channel.group.toLowerCase();
      return name.contains(query) || group.contains(query);
    }).toList();

    final groupedChannels = <String, List<Channel>>{};
    for (final channel in filteredChannels) {
      groupedChannels
          .putIfAbsent(channel.group, () => <Channel>[])
          .add(channel);
    }

    final orderedGroups = groupedChannels.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canais'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/import'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Importar'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar canal ou categoria',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (filteredChannels.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.errorMessage ??
                              (query.isEmpty
                                  ? 'Nenhuma playlist salva. Importe uma lista para começar.'
                                  : 'Nenhum canal encontrado para sua busca.'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: <Widget>[
                        for (final group in orderedGroups)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, bottom: 8),
                                  child: Text(
                                    group,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                ...groupedChannels[group]!.map((channel) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          child: Text(
                                            channel.name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                          ),
                                        ),
                                        title: Text(channel.name),
                                        subtitle: Text(channel.group),
                                        trailing: const Icon(
                                          Icons.play_arrow_rounded,
                                        ),
                                        onTap: () {
                                          final location = Uri(
                                            path: '/player',
                                            queryParameters: <String, String>{
                                              'name': channel.name,
                                              'url': channel.url,
                                            },
                                          );
                                          context.go(location.toString());
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
