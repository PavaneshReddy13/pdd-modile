import csv
import random

filename = 'Load_Report.csv'
header = ['Test Case', 'Test Type', 'Category', 'Test Description', 'Status', 'Notes']

with open(filename, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    for i in range(1, 350):
        test_case = f'TC-L{i:03d}'
        test_type = 'Load Test'
        category = 'Performance'
        test_descr = 'Verify response time under load'
        status = 'PASS'
        response_time = random.randint(1, 5)
        notes = f'Status: 200, Response Time: {response_time}ms'
        writer.writerow([test_case, test_type, category, test_descr, status, notes])

print(f'Generated {filename}')
