# Exercise Assets

This folder contains images and videos for exercises from the exercise library.

## Structure

```
exercise-assets/
├── images/     # Exercise images (.jpg, .png)
└── videos/     # Exercise videos (.mp4)
```

## Asset Mapping

The CSV file (`exercises_data.csv`) contains source URLs that need to be mapped to local assets.

### Mapping Rules

1. **Image files**: Place in `images/` folder
   - CSV source: `https://pump-app.s3.eu-west-2.amazonaws.com/exercise-assets/28931101-Scissors-(advanced)-(female)_small.jpg`
   - Local path: `exercise-assets/images/28931101-Scissors-(advanced)-(female)_small.jpg`

2. **Video files**: Place in `videos/` folder
   - CSV source: `https://pump-app.s3.eu-west-2.amazonaws.com/exercise-assets/08571201-Wheel-Rollout_Waist.mp4`
   - Local path: `exercise-assets/videos/08571201-Wheel-Rollout_Waist.mp4`

### File Naming

The service automatically extracts the filename from the CSV source URL and maps it to the local asset path. Make sure the filenames in your local folders match exactly with the filenames in the CSV.

### Adding Assets

1. Download images/videos from the source URLs in the CSV
2. Place them in the appropriate folder (`images/` or `videos/`)
3. Ensure filenames match exactly (case-sensitive)
4. Run `flutter pub get` to refresh assets
5. Restart the app

### Missing Assets

If an asset is missing, the app will display a placeholder icon. This is expected behavior and won't break functionality.

