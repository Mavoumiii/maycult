ALTER TABLE paragraphe
  ADD COLUMN media_type VARCHAR(50) NOT NULL DEFAULT 'video/mp4' AFTER video;
