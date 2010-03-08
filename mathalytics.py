from googleanalytics import *
from random import choice
import datetime
import string

def randstr():
  chars = string.letters + string.digits
  str = ""
  for i in range(10):
    str = str + choice(chars)
  return str

def datelst2date(lst):
  return datetime.date(lst[0], lst[1], lst[2])

class Mathalytics:
  def __init__(self):
    self.acs = None
    self.liveacs = {}
    self.con = None

  def accounts(self):
    return [x.title for x in self.acs]

  def account_by_title(self, title):
    ac = [x for x in self.acs if x.title == title][0]
    k = randstr()
    self.liveacs[k] = ac
    return k

  def account(self, key):
    return self.liveacs[key]

  def connect(self, user, pw):
    self.con = Connection(user, pw)
    self.acs = self.con.get_accounts()

  def filter(self, data):
    return [(x.dimensions, x.metrics) for x in data]

  def get_data(self, ackey, start, end, dimensions=[], metrics=[], sort=[], filters=[]):
    start = datelst2date(start)
    end = datelst2date(end)
    return self.filter(self.account(ackey).get_data(start_date=start, end_date=end, dimensions=dimensions, metrics=metrics, sort=sort, filters=filters))

m = Mathalytics()
myac = None

def test():
  global myac
  m.connect('username', 'password')
  myac = m.account_by_name('accountname')
