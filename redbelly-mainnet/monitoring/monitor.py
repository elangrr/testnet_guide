import argparse
from datetime import datetime, timezone, timedelta
import requests
import time
from dateutil import parser as date_parser
from decimal import Decimal
import logging
import os
import json
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

ether_in_wei = Decimal("1000000000000000000")
blockChanges: list[tuple[int, datetime]] = []

def format_duration(td: timedelta) -> str:
    """Format timedelta for better readability with days conversion"""
    total_seconds = int(td.total_seconds())
    
    if total_seconds < 0:
        return "EXPIRED"
    
    days = total_seconds // 86400
    hours = (total_seconds % 86400) // 3600
    minutes = (total_seconds % 3600) // 60
    
    if days > 0:
        if hours > 0:
            return f"{days}d {hours}h {minutes}m ({days} days)"
        else:
            return f"{days}d {minutes}m ({days} days)"
    elif hours > 0:
        return f"{hours}h {minutes}m"
    else:
        return f"{minutes}m"

class TelegramBot:
    def __init__(self, token: str, chat_id: str):
        self.token = token
        self.chat_id = chat_id
        self.base_url = f"https://api.telegram.org/bot{token}"
        
    def send_message(self, message: str):
        """Send message to Telegram chat"""
        url = f"{self.base_url}/sendMessage"
        data = {
            "chat_id": self.chat_id,
            "text": message,
            "parse_mode": "HTML"
        }
        
        try:
            response = requests.post(url, json=data, timeout=10)
            response.raise_for_status()
            logger.info("Status sent to Telegram")
            return True
        except Exception as e:
            logger.error(f"Failed to send to Telegram: {e}")
            return False

def clear_screen():
    print("\033[2J\033[H", end='', flush=True)

def get_block_ps(blockChange: list[tuple[int, datetime]]) -> float:
    if len(blockChange) < 2:
        return 0
    
    (startBlock, startTime) = blockChange[0]
    (endBlock, endTime) = blockChange[-1]
    timeChange = endTime.replace(tzinfo=timezone.utc) - startTime.replace(tzinfo=timezone.utc)
    if timeChange.total_seconds() == 0:
        return 0
    return float(endBlock - startBlock) / timeChange.total_seconds()

def get_governor_status():
    """Check governor status from metrics endpoint"""
    try:
        response = requests.get("http://localhost:8080/metrics", timeout=5)
        response.raise_for_status()
        
        for line in response.text.split('\n'):
            if line.startswith('is_governor ') and not line.startswith('#'):
                # Extract value from line like "is_governor 1"
                parts = line.split()
                if len(parts) >= 2:
                    value = int(parts[1])
                    if value == 0:
                        return "🟡 Candidate"
                    elif value == 1:
                        return "🟢 Governor"
                    else:
                        return f"❓ Unknown ({value})"
        
        return "❌ Metric Not Found"
        
    except requests.exceptions.RequestException:
        return "❌ Metrics Unavailable"
    except Exception as e:
        return f"❌ Error: {str(e)[:20]}"
    """Format timedelta for better readability"""
    total_seconds = int(td.total_seconds())
    if total_seconds < 60:
        return f"{total_seconds}s"
    elif total_seconds < 3600:
        minutes = total_seconds // 60
        seconds = total_seconds % 60
        return f"{minutes}m {seconds}s"
    else:
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        return f"{hours}h {minutes}m"

def create_telegram_message(address: str, min_balance: int) -> str:
    """Get status and create Telegram message"""
    url = address + "/status"
    
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        return f"🚨 <b>CONNECTION ERROR</b>\n\nCannot connect to {url}\nError: {str(e)}"
    
    # Parse all the data
    isRecoveryComplete = bool(data["isRecoveryComplete"])
    
    lastCommittedBlockAt = datetime.fromtimestamp(0) if data["lastCommittedBlockAt"] == "" else date_parser.parse(data["lastCommittedBlockAt"])
    timeSinceLastBlock = datetime.now(timezone.utc) - lastCommittedBlockAt.replace(tzinfo=timezone.utc)
    
    currentBlock = int(data["currentBlock"])
    lastBlockFromGovernors = int(data["lastBlockFromGovernors"])
    lastSyncedWithGovernorNodes = datetime.fromtimestamp(0) if data["lastSyncedWithGovernorNodes"] == "" else date_parser.parse(data["lastSyncedWithGovernorNodes"])
    timeSinceLastSyncWithGovs = datetime.now(timezone.utc) - lastSyncedWithGovernorNodes.replace(tzinfo=timezone.utc)
    blocksBehind = lastBlockFromGovernors - currentBlock
    
    blockChanges.append((currentBlock, lastCommittedBlockAt))
    if len(blockChanges) > 10:
        blockChanges.pop(0)
    
    currentSuperblock = int(data["currentSuperblock"])
    lastSyncedWithBootnodes = datetime.fromtimestamp(0) if data["lastSyncedWithBootnodes"] == "" else date_parser.parse(data["lastSyncedWithBootnodes"])
    lastSuperblockFromBootnodes = int(data["lastSuperblockFromBootnodes"])
    timeSinceLastSyncWithBootnodes = datetime.now(timezone.utc) - lastSyncedWithBootnodes.replace(tzinfo=timezone.utc)
    superblocksBehind = lastSuperblockFromBootnodes - currentSuperblock
    
    certificateDnsNames: list[str] = data["certificateDnsNames"]
    certificatesValidUpto = datetime.fromtimestamp(0) if data["certificatesValidUpto"] == "" else date_parser.parse(data["certificatesValidUpto"])
    certificateValidDuration = certificatesValidUpto.replace(tzinfo=timezone.utc) - datetime.now(timezone.utc)
    
    signingAddress = str(data["signingAddress"])
    signingAddressBalance = Decimal(data["signingAddressBalance"]) / ether_in_wei
    
    version = str(data["version"])
    
    # Get governor status
    governor_status = get_governor_status()
    
    # Create message
    message_parts = []
    warnings = []
    
    # Header
    message_parts.append("📊 <b>Redbelly Node Status Report</b>")
    message_parts.append("")
    
    # Sync status
    if isRecoveryComplete:
        message_parts.append("🟢 <b>Sync Status:</b> Complete")
    else:
        message_parts.append("🟡 <b>Sync Status:</b> Initial sync in progress")
    
    # Block info
    message_parts.append(f"📦 <b>Current Block:</b> {currentBlock:,}")
    message_parts.append(f"📈 <b>Governor Block:</b> {lastBlockFromGovernors:,}")
    if blocksBehind > 0:
        message_parts.append(f"⏳ <b>Blocks Behind:</b> {blocksBehind}")
        if blocksBehind > 100:
            warnings.append(f"Node is {blocksBehind} blocks behind")
    
    message_parts.append(f"⚡ <b>Block Rate:</b> {get_block_ps(blockChanges):.2f} blocks/sec")
    message_parts.append(f"🕐 <b>Last Block:</b> {format_duration(timeSinceLastBlock)} ago")
    
    if timeSinceLastBlock > timedelta(minutes=5):
        warnings.append("No block processed in 5+ minutes")
    
    # Superblock info
    message_parts.append("")
    message_parts.append(f"🏗️ <b>Current Superblock:</b> {currentSuperblock:,}")
    message_parts.append(f"📈 <b>Bootnode Superblock:</b> {lastSuperblockFromBootnodes:,}")
    if superblocksBehind > 0:
        message_parts.append(f"⏳ <b>Superblocks Behind:</b> {superblocksBehind}")
        if superblocksBehind > 100:
            warnings.append(f"Node is {superblocksBehind} superblocks behind")
    
    # Sync times
    message_parts.append("")
    message_parts.append(f"🔄 <b>Governor Sync:</b> {format_duration(timeSinceLastSyncWithGovs)} ago")
    if timeSinceLastSyncWithGovs > timedelta(minutes=1):
        warnings.append("Governor sync delayed 1+ minutes")
    
    message_parts.append(f"🔄 <b>Bootnode Sync:</b> {format_duration(timeSinceLastSyncWithBootnodes)} ago")
    if timeSinceLastSyncWithBootnodes > timedelta(minutes=2):
        warnings.append("Bootnode sync delayed 2+ minutes")
    
    # Balance
    message_parts.append("")
    message_parts.append(f"💰 <b>Signing Address:</b> <code>{signingAddress}</code>")
    message_parts.append(f"💰 <b>Balance:</b> {signingAddressBalance:.2f} RBNT")
    if signingAddressBalance < min_balance:
        warnings.append(f"Balance ({signingAddressBalance:.2f} RBNT) below minimum ({min_balance} RBNT)")
    
    # Certificate
    message_parts.append("")
    message_parts.append(f"🔐 <b>Certificate DNS:</b> {', '.join(certificateDnsNames)}")
    cert_duration = format_duration(certificateValidDuration)
    if certificateValidDuration <= timedelta():
        message_parts.append("🔴 <b>Certificate:</b> EXPIRED")
        warnings.append("Certificate has expired")
    elif certificateValidDuration <= timedelta(days=7):
        message_parts.append(f"🟡 <b>Certificate:</b> Expires in {cert_duration}")
        warnings.append(f"Certificate expires in {cert_duration}")
    else:
        message_parts.append(f"🟢 <b>Certificate:</b> Valid for {cert_duration}")
    
    # Version and Governor Status
    message_parts.append("")
    message_parts.append(f"🔧 <b>Version:</b> {version}")
    message_parts.append(f"👑 <b>Governor Status:</b> {governor_status}")
    
    # Warnings
    if warnings:
        message_parts.append("")
        message_parts.append("⚠️ <b>WARNINGS:</b>")
        for warning in warnings:
            message_parts.append(f"• {warning}")
    
    # Timestamp
    message_parts.append("")
    message_parts.append(f"🕐 <i>Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}</i>")
    
    return "\n".join(message_parts)

def run_loop(address: str, min_balance: int, refresh_seconds: int, telegram_interval: int, telegram_bot=None):
    last_telegram_send = datetime.now() - timedelta(seconds=telegram_interval)
    
    # Send startup message
    if telegram_bot:
        startup_msg = "🚀 <b>Redbelly Monitor Started</b>\n\nMonitoring has begun. Full status reports will be sent regularly."
        telegram_bot.send_message(startup_msg)
    
    try:
        while True:
            # Console monitoring (every few seconds)
            result = monitor_console(address, min_balance)
            clear_screen()
            print(result)
            
            # Telegram reports (every X minutes)
            current_time = datetime.now()
            if telegram_bot and (current_time - last_telegram_send).total_seconds() >= telegram_interval:
                telegram_message = create_telegram_message(address, min_balance)
                if telegram_bot.send_message(telegram_message):
                    last_telegram_send = current_time
            
            time.sleep(refresh_seconds)
            
    except KeyboardInterrupt:
        print("\nExiting...")
        if telegram_bot:
            telegram_bot.send_message("🛑 <b>Redbelly Monitor Stopped</b>\nMonitoring has been stopped.")
    except Exception as e:
        error_msg = f"Connection error: {str(e)}"
        print(f"\n{error_msg}")
        if telegram_bot:
            telegram_bot.send_message(f"🚨 <b>Monitor Error</b>\n\n{error_msg}")
        exit(1)

def monitor_console(address: str, min_balance: int) -> str:
    """Console monitoring (simplified version)"""
    url = address + "/status"
    parts = []
    
    parts.append(f"Monitoring: {url}")
    
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        data = response.json()
        
        currentBlock = int(data["currentBlock"])
        signingAddressBalance = Decimal(data["signingAddressBalance"]) / ether_in_wei
        isRecoveryComplete = bool(data["isRecoveryComplete"])
        governor_status = get_governor_status()
        
        parts.append(f"Block: {currentBlock:,}")
        parts.append(f"Balance: {signingAddressBalance:.2f} RBNT")
        parts.append(f"Sync: {'Complete' if isRecoveryComplete else 'In Progress'}")
        parts.append(f"Governor: {governor_status}")
        
        return "\n".join(parts)
        
    except Exception as e:
        return f"ERROR: Cannot connect to {url}\n{str(e)}"

def load_config():
    """Load configuration from file and environment variables"""
    config = {
        "node_address": "http://localhost:6539",
        "min_balance": 10,
        "refresh_seconds": 5,
        "telegram_interval": 3600, # Run Every Hour or ignore this
        "telegram_token": "", # You can hardcoded this or ignore it
        "telegram_chat_id": "" # You can hardcoded this or ignore it
    }
    
    # Load from config file if exists
    config_file = Path("redbelly_config.json")
    if config_file.exists():
        try:
            with open(config_file, 'r') as f:
                file_config = json.load(f)
                config.update(file_config)
                logger.info("Loaded config from redbelly_config.json")
        except Exception as e:
            logger.warning(f"Could not load config file: {e}")
    
    # Override with environment variables
    env_vars = {
        "REDBELLY_NODE_ADDRESS": "node_address",
        "REDBELLY_MIN_BALANCE": ("min_balance", int),
        "REDBELLY_REFRESH_SECONDS": ("refresh_seconds", int),
        "REDBELLY_TELEGRAM_INTERVAL": ("telegram_interval", int),
        "REDBELLY_TELEGRAM_TOKEN": "telegram_token",
        "REDBELLY_TELEGRAM_CHAT_ID": "telegram_chat_id"
    }
    
    for env_var, config_key in env_vars.items():
        env_value = os.getenv(env_var)
        if env_value:
            try:
                if isinstance(config_key, tuple):
                    key, converter = config_key
                    config[key] = converter(env_value)
                else:
                    config[config_key] = env_value
                logger.info(f"Loaded {env_var} from environment")
            except Exception as e:
                logger.warning(f"Invalid environment variable {env_var}: {e}")
    
    return config

def create_sample_config():
    """Create sample configuration file"""
    sample_config = {
        "node_address": "http://localhost:6539",
        "min_balance": 10,
        "refresh_seconds": 5,
        "telegram_interval": 3600, # you can ignore this
        "telegram_token": "YOUR_BOT_TOKEN_HERE", # You can hardcoded this or ignore it
        "telegram_chat_id": "YOUR_CHAT_ID_HERE" # You can hardcoded this or ignore it
    }
    
    with open("redbelly_config.json", 'w') as f:
        json.dump(sample_config, f, indent=4)
    
    print("✅ Sample config created: redbelly_config.json")
    print("📝 Edit the file with your actual values:")
    print("   - telegram_token: Get from @BotFather on Telegram")
    print("   - telegram_chat_id: Get from @userinfobot on Telegram")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Redbelly Node Monitor with Telegram Reports")
    parser.add_argument("--create-config", action="store_true", help="Create sample config file")
    parser.add_argument("-a", "--address", type=str, help="Override node address")
    parser.add_argument("-mb", "--minBalance", type=int, help="Override minimum balance")
    parser.add_argument("-r", "--refreshSeconds", type=int, help="Override console refresh rate")
    parser.add_argument("-ti", "--telegramInterval", type=int, help="Override telegram interval")
    parser.add_argument("-t", "--telegramToken", type=str, help="Override telegram token")
    parser.add_argument("-c", "--chatId", type=str, help="Override chat ID")
    
    args = parser.parse_args()
    
    # Create sample config if requested
    if args.create_config:
        create_sample_config()
        exit(0)
    
    # Load configuration
    config = load_config()
    
    # Apply command line overrides
    if args.address:
        config["node_address"] = args.address
    if args.minBalance is not None:
        config["min_balance"] = args.minBalance
    if args.refreshSeconds is not None:
        config["refresh_seconds"] = args.refreshSeconds
    if args.telegramInterval is not None:
        config["telegram_interval"] = args.telegramInterval
    if args.telegramToken:
        config["telegram_token"] = args.telegramToken
    if args.chatId:
        config["telegram_chat_id"] = args.chatId
    
    # Setup Telegram bot
    telegram_bot = None
    if config["telegram_token"] and config["telegram_chat_id"]:
        telegram_bot = TelegramBot(config["telegram_token"], config["telegram_chat_id"])
        logger.info("✅ Telegram bot enabled")
    else:
        logger.info("ℹ️  No Telegram credentials - console only mode")
        print("\n📱 To enable Telegram notifications:")
        print("   Method 1 - Environment variables:")
        print("     export REDBELLY_TELEGRAM_TOKEN='your_token'")
        print("     export REDBELLY_TELEGRAM_CHAT_ID='your_chat_id'")
        print("   Method 2 - Config file:")
        print("     python redbelly_monitor.py --create-config")
        print("   Method 3 - Command line:")
        print("     python redbelly_monitor.py -t 'token' -c 'chat_id'")
        print()
    
    logger.info(f"🚀 Starting monitor:")
    logger.info(f"   Node: {config['node_address']}")
    logger.info(f"   Console refresh: {config['refresh_seconds']}s")
    logger.info(f"   Telegram reports: {config['telegram_interval']}s")
    logger.info(f"   Min balance: {config['min_balance']} RBNT")
    
    run_loop(
        config["node_address"], 
        config["min_balance"], 
        config["refresh_seconds"], 
        config["telegram_interval"], 
        telegram_bot
    )
