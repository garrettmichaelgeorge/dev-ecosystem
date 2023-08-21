import pendulum

def print_date():
    now_in_paris = pendulum.now('Europe/Paris')
    print(now_in_paris)
