﻿
namespace SteamMobile.Commands
{
    public class Banned : Command
    {
        public override string Type
        {
            get { return "banned"; }
        }

        public override string Format
        {
            get { return ""; }
        }

        public override void Handle(CommandTarget target, string[] parameters)
        {
            if (target.Room == null)
                return;

            var banned = target.Room.Banned;

            if (banned.Count == 0)
                target.Send("Nobody is banned.");
            else
                target.Send(string.Format("Banned from this chat: {0}", string.Join(", ", banned)));
        }
    }
}
