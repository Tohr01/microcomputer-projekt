import csv
# Load memory_dump.csv
with open('memory_dump.csv', 'r') as file:
    reader = csv.reader(file)
    # Exclude the first row
    next(reader)
    # Store as dict with first column as key and second column as value
    memory_dump = {int(row[0]): int(row[1]) for row in reader if int(row[0]) >= 1000}

primes = []
for memory_addr, content in memory_dump.items():
    # Check if content is a prime number
    if content > 0:
        primes.append(content)

print(len(primes))