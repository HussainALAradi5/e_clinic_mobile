part of 'new_ticket_screen.dart';

/// The photos chosen for the ticket (up to five), each removable, and a button to add one.
class _PhotoPicks extends StatelessWidget {
  const _PhotoPicks({required this.photos, required this.onAdd, required this.onRemove});

  static const _max = 5;

  final List<XFile> photos;
  final ValueChanged<XFile> onAdd;
  final ValueChanged<XFile> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final photo in photos)
          InputChip(
            avatar: const Icon(Icons.image_outlined, size: 18),
            label: Text(photo.name, overflow: TextOverflow.ellipsis),
            onDeleted: () => onRemove(photo),
          ),
        if (photos.length < _max)
          TextButton.icon(
            onPressed: () async {
              final photo = await pickPhoto(context);
              if (photo != null) onAdd(photo);
            },
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(photos.isEmpty ? TicketText.addPhotoOrScreenshot : TicketText.addAnother),
          ),
      ],
    );
  }
}
