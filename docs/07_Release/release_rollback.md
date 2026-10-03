# Grow~ Rollback Procedures

## App Rollback (Play Store)
1. Go to Play Console -> Release -> Production
2. Click "Roll back release"
3. Select previous stable version
4. Rollback deploys within 1-2 hours

## Database Rollback
Supabase Point-in-Time Recovery (PITR):
- Free tier: no PITR - take manual exports before migrations
- To export current data: Supabase Dashboard -> Database -> Backups
- SQL: pg_dump -Fc --no-acl --no-owner -h HOST -U postgres DB > backup.dump

## Schema Rollback
All migrations in supabase/migrations/ are forward-only.
Before any migration, document the rollback SQL as a comment at top of the migration file.
