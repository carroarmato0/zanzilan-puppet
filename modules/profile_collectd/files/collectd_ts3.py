#
# Teamspeak 3 monitoring plugin for CollectD
# https://github.com/Silberling/collectd_teamspeak3
#
import telnetlib
import time

PLUGIN_NAME = "ts3_stats"

# COMMAND LINE CONFIG
# Because we don't know where the config file is (it is read by collectd)
HOST = '127.0.0.1'
PORT = '10011'
USERNAME = 'serveradmin'
PASSWORD = ''

TYPE_GAUGE = 'gauge'
TYPE_BYTES = 'bytes'

try:
	import collectd
except:
	import sys

	class CollectD:
		def register_config(self, callback):
			callback(None)

		def register_init(self, callback):
			callback()

		def register_read(self, callback):
			for i in range(0, 15):
				time.sleep(1)
				callback()
				time.sleep(1)

		def register_shutdown(self, callback):
			callback()

		def debug(self, message):
			sys.stdout.write(message)
			sys.stdout.flush()

		def error(self, message):
			sys.stdout.write(message)
			sys.stdout.flush()

		def warning(self, message):
			sys.stdout.write(message)
			sys.stdout.flush()

		def notice(self, message):
			sys.stdout.write(message)
			sys.stdout.flush()

		def info(self, message):
			sys.stdout.write(message)
			sys.stdout.flush()

		class Values:
			def __init__(self, plugin):
				self.plugin = plugin
				self.type = ""
				self.type_instance = ""
				self.values = []

			def dispatch(self):
				collectd.debug('\n' + self.type + ' ' + self.type_instance + ' [' + ', '.join(map(str, self.values)) + ']')

	collectd = CollectD()


class TS3DefaultException(Exception):
	pass

class TS3ServerQuery:
	__tn = None

	__NEWLINE = '\n\r'
	__STATUSLINE = 'error'

	def __init__(self, host, port, timeout = 3):
		self.__tn = telnetlib.Telnet(host, port, timeout)

		id_string = self.__read_line()
		if id_string == 'TS3':
			self.__read_line()


	def __send_command(self, command):
		self.__tn.write(command + self.__NEWLINE)

	def __read_line(self):
		return self.__tn.read_until(self.__NEWLINE)[:0-len(self.__NEWLINE)]

	def __read_dictionary(self):
		return self.__string_to_dictionary(self.__read_line())

	def __read_until_statusline(self, allowedErrorIDArray = []):
		results = []
		while True:
			line = self.__read_dictionary()
			if not self.__response_is_status(line):
				results.append(line)
			else:
				if int(line['id']) in ([0] + allowedErrorIDArray):
					return results

				raise TS3DefaultException('Command failed', line)

	def __response_is_status(self, dictionary):
		return self.__STATUSLINE in dictionary.keys()


	def __expect_statusline_success(self):
		line = self.__read_dictionary()
		if self.__response_is_status(line) and int(line['id']) == 0:
			return True

		raise TS3DefaultException('Command failed', line)

	def __expect_dictionaryline(self):
		line = self.__read_dictionary()
		if self.__response_is_status(line):
			raise TS3DefaultException('Command failed', line)

		return line


	def __string_to_dictionary(self, string):
		array = string.split(' ')
		dictionary = {}

		for param in array:
			parameter = param.split('=', 2)
			if len(parameter) == 1:
				dictionary[parameter[0]] = ''
			if len(parameter) == 2:
				dictionary[parameter[0]] = parameter[1]

		return dictionary


	def login(self, username, password):
		self.__send_command('login {0} {1}'.format(username, password))
		self.__expect_statusline_success()

	def serverlist(self):
		self.__send_command('serverlist')
		return self.__read_until_statusline()

	def use(self, virtualServerId):
		self.__send_command('use {0}'.format(virtualServerId))
		self.__expect_statusline_success()

	def ftlist(self):
		self.__send_command('ftlist')
		return self.__read_until_statusline([1281])

	def quit(self):
		self.__send_command('quit')
		self.__expect_statusline_success()


class TS3ServerStats:
	__TS3SQ = None

	def __init__(self, host, port, username, password):
		self.__TS3SQ = TS3ServerQuery(host, int(port))
		if self.__TS3SQ:
			self.__TS3SQ.login(username, password)
		else:
			self.__TS3SQ = None
			raise TS3DefaultException()

	def __del__(self):
		if self.__TS3SQ:
			self.__TS3SQ.quit()


	def __get_clientsonline(self):
		return int(self.__TS3SQ.serverlist()[0]['virtualserver_clientsonline'])

	def __get_filetransfer_vs_total(self, virtualServerID):
		self.__TS3SQ.use(virtualServerID)
		transfers = self.__TS3SQ.ftlist()

		result = {
			'count': 0,
			'current_speed': 0.0
		}
		for transfer in transfers:
			result['count'] += 1
			result['current_speed'] += float(transfer['current_speed'])

		return result


	def getMyStats(self):
		results = {}

		for server in self.__TS3SQ.serverlist():
			filetransfer = self.__get_filetransfer_vs_total(server['virtualserver_id'])
			results[server['virtualserver_id']] = {
				'clients_online':		int(server['virtualserver_clientsonline']),
				'filetransfer_count':	filetransfer['count'],
				'filetransfer_speed':	filetransfer['current_speed']
			}

		return results


def __newCollectdValue(plugin_name, type, type_instance, values):
	global collectd

	val = collectd.Values(plugin = plugin_name)
	val.type			= type
	val.type_instance	= type_instance
	val.values			= values
	val.dispatch()


ts3config = None
ts3 = None

def __connectTS3():
	global ts3
	global ts3config

	if ts3 == None:
		try:
			ts3 = TS3ServerStats(ts3config['Host'], int(ts3config['Port']), ts3config['Username'], ts3config['Password'])
		except Exception as e:
			ts3 = None
			raise e

def __getStatsTS3():
	global ts3

	try:
		if ts3 != None:
			return ts3.getMyStats()
		else:
			raise TS3DefaultException()
	except:
		ts3 = None
		raise TS3DefaultException()

def __disconnectTS3():
	global ts3

	ts3 = None


def ts3_config(config):
	global ts3config

	collectd.debug('ts3_config:\n')

	ts3config = {};

	if config != None:
		for node in config.children:
			ts3config[node.key] = node.values[0]
	else:
		global HOST
		global PORT
		global USERNAME
		global PASSWORD
		ts3config['Host'] =		HOST
		ts3config['Port'] =		PORT
		ts3config['Username'] =	USERNAME
		ts3config['Password'] =	PASSWORD

	for key in ts3config:
		collectd.debug('\t' + key + ': ' + ts3config[key] + '\n')

def ts3_init():
	collectd.debug('ts3_init:')

	try:
		__connectTS3()
		collectd.debug('ok\n')
	except Exception as e:
		collectd.debug('FAILED\n')
		collectd.warning(str(e) + '\n')

def ts3_read():
	global PLUGIN_NAME

	global TYPE_GAUGE
	global TYPE_BYTES

	collectd.debug('ts3_read:')

	# Reconnect if connection was lost or TS3 is not up yet
	try:
		__connectTS3()
	except Exception as e:
		collectd.debug('FAILED\n')
		collectd.warning(str(e) + '\n')

	try:
		stats = __getStatsTS3();

		collectd.debug('ok')

		for sid in stats.keys():
			server = stats[sid]

			__newCollectdValue(PLUGIN_NAME, TYPE_GAUGE, 'ts3vs' + str(sid) + '_clients_online', [server['clients_online']])
			__newCollectdValue(PLUGIN_NAME, TYPE_GAUGE, 'ts3vs' + str(sid) + '_filetransfer_count', [server['filetransfer_count']])
			__newCollectdValue(PLUGIN_NAME, TYPE_BYTES, 'ts3vs' + str(sid) + '_filetransfer_speed', [server['filetransfer_speed']])
	except Exception as e:
		collectd.warning(str(e))
		collectd.debug('SKIP')

	collectd.debug('\n')

def ts3_shutdown():
	collectd.debug('ts3_shutdown:\n')

	try:
		__disconnectTS3()
		collectd.debug('ok\n')
	except Exception as e:
		collectd.debug('FAILED\n')
		collectd.warning(str(e) + '\n')

collectd.register_config(ts3_config)
collectd.register_init(ts3_init)
collectd.register_read(ts3_read)
collectd.register_shutdown(ts3_shutdown)
