﻿using System.Linq;
using EzSteam;
using SteamMobile.Rooms;

namespace SteamMobile.Commands
{
    public class Ban : Command
    {
        public override string Type { get { return "ban"; } }

        public override string Format { get { return "]"; } }

        public override void Handle(CommandTarget target, string[] parameters)
        {
            if (!target.IsRoom || parameters.Length == 0)
                return;


            var room = target.Room as SteamRoom;
            if (room != null)
            {
                var member = room.Chat.Group.Members.FirstOrDefault(m => m.Id == target.SteamId);
                if (member == null || (member.Rank != ClanRank.Owner && member.Rank != ClanRank.Officer && member.Rank != ClanRank.Moderator))
                    return;

                if (!Util.IsValidUsername(parameters[0]))
                {
                    target.Send("Invalid username.");
                    return;
                }

                target.Room.Ban(parameters[0]);
                target.Send("Account banned.");
            }
        }
    }
}
