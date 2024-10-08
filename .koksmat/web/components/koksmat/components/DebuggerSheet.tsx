"use client";

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import Debugger from "@/components/koksmat/components/debugger";
import { MagicboxContext } from "@/components/koksmat/magicbox-context";
import { useContext } from "react";

export default function DebuggerSheet() {
  const magicbox = useContext(MagicboxContext);
  return (
    <div>
      <Sheet>
        <SheetTrigger>M</SheetTrigger>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>Debugger</SheetTitle>
          </SheetHeader>

          <Debugger />
          <SheetFooter></SheetFooter>
        </SheetContent>
      </Sheet>
    </div>
  );
}
