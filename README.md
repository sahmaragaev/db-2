## Running the Script

1. **Using psql command line:**

   ```bash
   psql -U username -d database -f student_exam_db.sql
   ```

2. **Using any PostgreSQL client:**

   - Open your preferred PostgreSQL client
   - Connect to your database
   - Import and execute the `student_exam_db.sql` file using the client's interface

## Verification

After running the script, you can verify the setup by querying one of the views:

```sql
SELECT * FROM student_exam_view;
```
