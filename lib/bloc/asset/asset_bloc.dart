import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Asset Events
abstract class AssetEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Event to load initial assets
class LoadAssets extends AssetEvent {}

// Event to add a new asset
class AddAsset extends AssetEvent {
  final String assetName;

  AddAsset(this.assetName);

  @override
  List<Object> get props => [assetName];
}

// Asset States
abstract class AssetState extends Equatable {
  @override
  List<Object> get props => [];
}

class AssetInitial extends AssetState {}

class AssetLoading extends AssetState {}

class AssetsLoaded extends AssetState {
  final List<String> assets;

  AssetsLoaded(this.assets);

  @override
  List<Object> get props => [assets];
}

class AssetError extends AssetState {
  final String message;

  AssetError(this.message);

  @override
  List<Object> get props => [message];
}

// Asset Bloc
class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetBloc() : super(AssetInitial()) {
    on<LoadAssets>(_onLoadAssets);
    on<AddAsset>(_onAddAsset);
  }

  // Handler for loading assets
  void _onLoadAssets(LoadAssets event, Emitter<AssetState> emit) {
    emit(AssetLoading());
    // Simulate loading assets (fetch from a database or API)
    // Replace the below list with actual asset fetching logic
    final initialAssets = ['Bitcoin', 'Ethereum'];
    emit(AssetsLoaded(initialAssets));
  }

  // Handler for adding a new asset
  void _onAddAsset(AddAsset event, Emitter<AssetState> emit) {
    if (state is AssetsLoaded) {
      final currentAssets = (state as AssetsLoaded).assets;
      emit(AssetsLoaded([...currentAssets, event.assetName]));
    }
  }
}
