from src.print_date import print_date

def test_prints_something_to_stdout(capsys):
    print_date()
    stdout, stderr = capsys.readouterr()
    assert stdout != ""
