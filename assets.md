# Required Assets

To ensure the application runs correctly and looks as designed, please download or create the following image assets and place them in the specified directories.

## 1. Directory Structure

Ensure your `assets` folder has the following subdirectories:

```
assets/
├── avatars/
├── images/
└── app_Icon.png (Existing)
```

## 2. Pubspec Configuration

Update your `pubspec.yaml` to explicitly include these subdirectories:

```yaml
flutter:
  assets:
    - assets/
    - assets/avatars/
    - assets/images/
```

## 3. Required Images

### Avatars (`assets/avatars/`)
Used for user profiles, bots, and match history. You can use any square PNG/JPG images (recommended size: 200x200px).

- `avatar1.png` (Default user avatar)
- `avatar2.png` (Opponent avatar)
- `avatar3.png` (Opponent avatar)
- `avatar4.png` (Opponent avatar)
- `alice.png` (Easy Bot avatar - e.g., friendly face)
- `marcus.png` (Medium Bot avatar - e.g., serious face)
- `stockfish.png` (Hard Bot avatar - or Stockfish logo)

### Images (`assets/images/`)
Used for banners and UI elements.

- `chess_board_thumb.png` (Thumbnail for "Play vs Computer" card)
- `daily_puzzle.png` (Background or icon for "Daily Puzzle" card)
- `learn_banner.png` (Banner image for the Learn screen - wide aspect ratio, e.g., 800x400px)

## 4. Note on Chess Pieces
The chess pieces have been downloaded directly from Wikimedia and are located in `assets/pieces/`. You no longer need to worry about network issues or missing black pieces due to rate limiting.
