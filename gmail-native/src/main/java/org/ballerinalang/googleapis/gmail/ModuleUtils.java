package org.ballerinalang.googleapis.gmail;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Module;

/**
 * {@code ModuleUtils} contains the utility methods for the module.
 * 
 * @since 2.0.0
 */
public class ModuleUtils {

    private static Module httpListenerModule;

    private ModuleUtils() {}

    public static void setModule(Environment environment) {
        httpListenerModule = environment.getCurrentModule();
    }

    public static Module getModule() {
        return httpListenerModule;
    }
}
