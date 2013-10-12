﻿using SteamMobile.Packets;

namespace SteamMobile.Commands
{
    public class Me : Command
    {
        public override string Type { get { return "me"; } }

        public override string Format { get { return "]"; } }

        public override void Handle(CommandTarget target, string[] parameters)
        {
            if (!target.IsSession || target.Session.Account == null || parameters.Length == 0)
            {
                return;
            }

            var room = Program.RoomManager.Get(target.Session.Room);
            if (room == null)
            {
                target.Session.Send(new SysMessage
                {
                    Date = Util.GetCurrentUnixTimestamp(),
                    Content = "RohBot is not in the current chat."
                });
                return;
            }

            if (room.IsBanned(target.Session.Account.Name))
            {
                target.Send("You are banned from this chat.");
                return;
            }

            room.Send(string.Format("{0} {1}", target.Session.Account.Name, parameters[0]));
        }
    }
}
