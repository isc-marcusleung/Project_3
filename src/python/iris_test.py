import iris
import sys

def main(argv):

	try:
		st = iris.cls('cdu.Person').PopulateData(10,True)
		iris.check_status(st)
	except Exception as e:
		print(f'Exception encountered running populate: {str(e)}')
		sys.exit(1)
	
	print('Database populated.')

	try:
		rset = iris.sql.exec("SELECT Name, %ODBCOUT(DateOfBirth) FROM cdu.Person") 
		for row in rset:
			print(row)
	except Exception as e:
		print(f'Exception encountered fetching data: {str(e)}')
		sys.exit(1)
	

if __name__ == "__main__":
	main(sys.argv[1:])
